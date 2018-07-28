
object Main extends App {
  //val pgen = new PolyhedraGenerator("components/tetrahedron_edges.txt")
  //val pgen = new PolyhedraGenerator("components/dodecahedron_edges.txt")
  //val pgen = new PolyhedraGenerator("components/snub_cube_edges.txt")
  val pgen = new PolyhedraGenerator("components/truncated_cuboctahedron_edges.txt")
}

case class Edge private (a: Int, b: Int) {
  override def equals(edgb: Any) = {
    edgb match {
      case edg:Edge =>
        (a == edg.a && b == edg.b) ||
        (a == edg.b && b == edg.a)
      case _ => false
    }
  }

  override def hashCode() = a+b
}

object Edge {
  def apply(a: Int, b: Int): Edge = {
    if(a<b)
      new Edge(a,b)
    else new Edge(b,a)
  }
}

case class Face(vertices: Int *) {
  override def equals(faceb: Any) = {
    faceb match {
      case f:Face =>
        val test = Set(vertices:_*).diff(Set(f.vertices:_*))
        test.isEmpty
      case x: Any => {
        false
      }
    }
  }

  override def hashCode() = vertices.sum
}


class PolyhedraGenerator(edgesFile: String) {
  import scala.io.Source
  import scala.util.matching.Regex
  import scala.collection.mutable

  val fileRegex = new Regex("""\A\s*\[\s*(\[\s*\d+\s*,\s*\d+\s*\]\s*,\s*)*\[\s*\d+\s*,\s*\d+\s*\]\s*\]\s*\z""")
  val tupleRegex = new Regex("""\[\s*(\d+)\s*,\s*(\d+)\s*\]""")
  def readEdgesFile(filename: String): Seq[Edge] = {
    val lines = scala.io.Source.fromFile(filename).mkString
    val fileMatcher = fileRegex.pattern.matcher(lines)
    if(fileMatcher.matches()) {
      val tupleMatcher = tupleRegex.pattern.matcher(lines)
      val edges = mutable.ArrayBuffer[Edge]()
      while(tupleMatcher.find) {
        edges += Edge(tupleMatcher.group(1).toInt, tupleMatcher.group(2).toInt)
      }
      edges
    } else {
      throw new Exception("Unable to parse edges file")
    }
  }

  def findAdjacentVertices(edges: Seq[Edge]): Map[Int, Set[Int]] = {
    val map = new mutable.HashMap[Int, mutable.HashSet[Int]]()
    edges.foreach{
      case Edge(a,b) =>
         if(map.contains(a)) {map(a) += b}
         else {map.put(a,mutable.HashSet(b))}
         if(map.contains(b)) {map(b) += a}
         else {map.put(b,mutable.HashSet(a))}
    }
    map.toMap.mapValues(_.toSet)
  }

  sealed trait BfsTestResult[+T]
  case object Continue extends BfsTestResult[Nothing]
  case object DoNotContinue extends BfsTestResult[Nothing]
  case class Solution[+T](t: T) extends BfsTestResult[T]

  def bfs[T,S](root: Seq[T])(neighbors: Seq[T] => Seq[Seq[T]])(test: Seq[T] => BfsTestResult[S]): Option[S] = {
    val queue = mutable.Queue[Seq[T]]()
    queue ++= neighbors(root)
    var solution = Option.empty[S]
    while(queue.nonEmpty && solution.isEmpty) {
      val possibleSolution = queue.dequeue()
      test(possibleSolution) match {
        case Continue =>
          queue ++= neighbors(possibleSolution)
        case DoNotContinue =>
          {}
        case Solution(s) =>
          solution = Some(s)
      }
    }
    return solution
  }

  def getFirstCycle(start: Int, adjacentVerts: Map[Int, Set[Int]]): Face = {
    bfs[Int,Face](Seq(start)){
      path =>
        adjacentVerts(path(0))
          .filter{i =>
            (path.size==1 || i != path(1)) && i != path(0)
          }
          .map{i =>
            i +: path
          }
          .toSeq
    }{
      path =>
        if(path.size > 1 && path.head == path.last)
          Solution(Face(path.tail:_*))
        else
          Continue
    }.get
  }

  def getMissingCycle(start: Edge, adjacentVerts: Map[Int, Set[Int]], edges: mutable.HashMap[Edge, Seq[Face]], faces: mutable.HashSet[Face]): Face = {
    println("get missing cycle: ")
    println(s"start: ${start}")
    println(s"edges: ${edges}")

    bfs[Int,Face](Seq(start.a, start.b)){
      path =>
        adjacentVerts(path(0))
          .filter{ nextVert =>
            //not going back from where we came
            nextVert != path(1)
          }
          .filter{ nextVert =>
            //edge does not already have two faces
            edges.get(Edge(nextVert, path(0))).map(_.size<2).getOrElse(true)
          }
          .map{ nextVert =>
            nextVert +: path
          }.toSeq
    }{ path =>
      val closed = path.head == path.last
      if(closed) {
        val face = Face(path.tail:_*)
        if(!faces.contains(face)) {
          Solution(face)
        } else DoNotContinue
      } else
        Continue
    }.get
  }

  def dfCa2(start: Edge, adjacentVerts: Map[Int, Set[Int]], edges: mutable.HashMap[Edge,Seq[Face]], faces: mutable.HashSet[Face]): Face = {
    val queue = mutable.Queue[Seq[Int]]()
    queue ++= adjacentVerts(start.b)
      .map{ i =>
        Seq(i, start.b, start.a)
      }
      .filter{ possiblePath =>
        val lastEdge = Edge(possiblePath(0), possiblePath(1))
        val penultimateEdge = Edge(possiblePath(1), possiblePath(2))
        edges.get(lastEdge).size<2 && penultimateEdge != lastEdge
      }
    var cycle = Option.empty[Face]
    while(cycle.isEmpty) {
      val path = queue.dequeue
      val newPaths =
        adjacentVerts(path(0))
          .filterNot(_ == path(1))
          .filter{ i =>
            val lastEdge = Edge(i, path(0))
            edges.get(lastEdge).size < 2
          }
          .map { i =>
            i +: path
          }
      queue ++= newPaths
      val cycleOpt = newPaths.find{
        path =>
          path.head == path.last
      }
      cycleOpt.foreach{ c =>
        val face = Face(c.tail:_*)
        if(!faces.contains(face)) {
          cycle = Some(face)
        }
      }
    }
    cycle.get
  }

  def addFaceToEdges(face: Face, ef: mutable.HashMap[Edge,Seq[Face]]) = {
    for{ i <- 0 until face.vertices.size} {
      val edge = Edge(face.vertices(i), face.vertices((i+1) % face.vertices.size))
      ef.get(edge) match {
        case Some(faces) =>
          ef += edge -> (faces :+ face)
        case None =>
          ef += edge -> Seq(face)
      }
    }
  }


  val edges = readEdgesFile(edgesFile)
  val adjacentVerts = findAdjacentVertices(edges)
  val edgeFaces = mutable.HashMap[Edge, Seq[Face]](
    edges.map{edge =>
      edge -> Seq.empty[Face]
    }:_*
  )
  val faces = mutable.HashSet[Face]()

  val firstCycle = getFirstCycle(0, adjacentVerts)
  addFaceToEdges(firstCycle, edgeFaces)
  faces += firstCycle

  def remainingEdges(ef: mutable.HashMap[Edge, Seq[Face]]) = {
    ef.filter{
      case (edge, faces) =>
        faces.size < 2
    }.keySet
  }

  try {
    var remaining = remainingEdges(edgeFaces).toSeq
    while(remaining.nonEmpty) {
      val startEdge = remaining.head
      //val newFace = dfCa2(start = startEdge, adjacentVerts = adjacentVerts, edges = edgeFaces, faces = faces)
      val newFace = getMissingCycle(start = startEdge, adjacentVerts = adjacentVerts, edges = edgeFaces, faces = faces)
      addFaceToEdges(newFace, edgeFaces)
      println(s"new face: ${newFace}")
      scala.io.StdIn.readLine()
      faces += newFace
      remaining = remainingEdges(edgeFaces).toSeq
    }
  } catch {
    case t:Throwable => t.printStackTrace()
  }


  edgeFaces.foreach{
    case (edge, faces) =>
      println(s"$edge: ${faces.size} ${faces}")
  }
  println(edgeFaces.size)
  println()
  faces.foreach{
    case f:Face =>
      println(s"face: ${f.vertices.size} - ${f}")
  }
  println(faces.size)
}
