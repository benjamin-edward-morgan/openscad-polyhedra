
polyhedra_examples();


module show_verts(verts,r=0.1,$fn=32) {
    for(i=[0:len(verts)-1])
    translate(verts[i])
    sphere(r=r);
}

module orient_verts(verts,adjacents,n=1,r=0.1) {
    for(i=[0:len(verts)-1])                  
    orient_vertex(verts[i],verts[adjacents[i]])
    for(i=[0,1])
    mirror([0,0,i])
    for(j=[0:n-1])
    rotate(j*360/n)
    linear_extrude(height=3*r,scale=0)
    translate([r/2,0,0])
    circle(r=r/2);    
    
}

module show_edges(verts, edges,r=0.05,$fn=16) {
    for(i=[0:len(edges)-1]) {
        a = verts[edges[i][0]];
        b = verts[edges[i][1]];        
        
        orient_edge(a,b)
        linear_extrude(height=norm(a-b),center=true)
        union() {
            circle(r=r);
            rotate(-45)
            square(size=r);
        }      
    }
}

module orient_edge(a,b) {
  u = (a+b)/2;    
  uhat = u/norm(u);
  what = (a-b)/norm(a-b);
  vhat = cross(what,uhat);  
   
  mat = 
  [[uhat[0], vhat[0], what[0], u[0]],
   [uhat[1], vhat[1], what[1], u[1]],
   [uhat[2], vhat[2], what[2], u[2]],
   [0, 0, 0, 1]]; 
    
  multmatrix(mat)
   children(); 
}

module orient_vertex(a,b) {
  ahat = a/norm(a);
  qhat = (b-a)/norm(b-a);
  chat = cross(b,a)/norm(cross(b,a));
  bhat = cross(ahat,chat)/norm(cross(ahat,chat));
    
  mat = 
  [[bhat[0],chat[0],ahat[0],a[0]],
   [bhat[1],chat[1],ahat[1],a[1]],
   [bhat[2],chat[2],ahat[2],a[2]],  
   [0,0,0,1]];
   
  multmatrix(mat)
  children();  
}

module polyhedra_examples() {
    scale(6) {    
        translate([-2,-4,0])
        tetrahedron();

        translate([0,-4,0])
        hexahedron();

        translate([2,-4,0])
        octahedron();

        translate([-1.5,0,0])
        dodecahedron();

        translate([1.5,0,0])
        icosahedron();

        translate([-2,4,0])
        cubeoctahedron();

        translate([2,4,0])
        icosidodecahedron();
    }
}

//tetrahedron();
module tetrahedron() {
  color("brown")    
  orient_verts(tetrahedron_vertices,tetrahedron_adjacent_vertices,3);  

  color("magenta")
  show_edges(tetrahedron_vertices, tetrahedron_edges); 
    
}

//hexahedron();
module hexahedron() {
  color("blue")
  orient_verts(hexahedron_vertices,hexahedron_adjacent_vertices,3);  

  color("green")
  show_edges(hexahedron_vertices, hexahedron_edges);
}

//octahedron();
module octahedron() {
  color("orangered")
  orient_verts(octahedron_vertices,octahedron_adjacent_vertices,4); 
    
  color("khaki")
  show_edges(octahedron_vertices, octahedron_edges);  
}

//dodecahedron();
module dodecahedron() {
  color("darkorchid")
  orient_verts(dodecahedron_vertices,dodecahedron_adjacent_vertices,3); 
      
  color("lightseagreen")
  show_edges(dodecahedron_vertices, dodecahedron_edges);  
}

//icosahedron();
module icosahedron() {
  color("cadetblue")
  orient_verts(icosahedron_vertices,icosahedron_adjacent_vertices,5); 
   
  color("crimson")
  show_edges(icosahedron_vertices, icosahedron_edges);  
}

//cubeoctahedron();
module cubeoctahedron() {
  color("blueviolet")
  show_verts(cubeoctahedron_vertices);
    
  color("springgreen")
  show_edges(cubeoctahedron_vertices, cubeoctahedron_edges);  
}

//icosidodecahedron();
module icosidodecahedron() {
  color("fuchsia")  
  show_verts(icosidodecahedron_vertices);

  color("green")
  show_edges(icosidodecahedron_vertices, icosidodecahedron_edges);
}


polyhedraPhi = (1 + sqrt(5))/2;
polyhedraPhiSq = polyhedraPhi*polyhedraPhi;

tetrahedron_vertices =
  [[1,1,1],
   [1,-1,-1],
   [-1,1,-1],
   [-1,-1,1]]/sqrt(8);

tetrahedron_edges =
  [[0,1],[1,2],[0,2],
   [2,3],[1,3],[0,3]];
   
tetrahedron_adjacent_vertices = 
  [1,2,3,1];


hexahedron_vertices = 
  [[-1,-1,-1],
   [ 1,-1,-1],
   [-1, 1,-1],
   [ 1, 1,-1],
   [-1,-1, 1],
   [ 1,-1, 1],
   [-1, 1, 1],
   [ 1, 1, 1]]/2;
   
hexahedron_edges = 
  [[0,1],[0,2],[1,3],[2,3],
   [4,5],[4,6],[5,7],[6,7],
   [0,4],[1,5],[2,6],[3,7]];
     
hexahedron_adjacent_vertices = 
  [1,3,3,7,5,7,7,6];


octahedron_vertices = 
  [[1,0,0],
   [-1,0,0],
   [0,1,0],
   [0,-1,0],
   [0,0,1],
   [0,0,-1]]/sqrt(2);
     
octahedron_edges = 
  [[0,2],[2,1],[1,3],[0,3],
   [0,4],[1,4],[2,4],[3,4],
   [0,5],[1,5],[2,5],[3,5]];
   
octahedron_adjacent_vertices = 
  [2,3,4,4,3,1];


dodecahedron_vertices = 
  [[-1,-1,-1],
   [ 1,-1,-1],
   [-1, 1,-1],
   [ 1, 1,-1],
   [-1,-1, 1],
   [ 1,-1, 1],
   [-1, 1, 1],
   [ 1, 1, 1],
   [ 0, polyhedraPhi, 1/polyhedraPhi],
   [ 0,-polyhedraPhi, 1/polyhedraPhi],
   [ 0, polyhedraPhi,-1/polyhedraPhi], 
   [ 0,-polyhedraPhi,-1/polyhedraPhi], 
   [ 1/polyhedraPhi, 0, polyhedraPhi], 
   [-1/polyhedraPhi, 0, polyhedraPhi], 
   [ 1/polyhedraPhi, 0,-polyhedraPhi], 
   [-1/polyhedraPhi, 0,-polyhedraPhi], 
   [ polyhedraPhi, 1/polyhedraPhi, 0], 
   [-polyhedraPhi, 1/polyhedraPhi, 0], 
   [ polyhedraPhi,-1/polyhedraPhi, 0], 
   [-polyhedraPhi,-1/polyhedraPhi, 0]]/(2/polyhedraPhi);

dodecahedron_edges = 
  [[8,10],[8,6],[8,7],[10,2],[10,3],
  [9,11],[9,4],[9,5],[11,0],[11,1],
  [12,13],[12,5],[12,7],[13,4],[13,6],
  [14,15],[14,1],[14,3],[15,0],[15,2],
  [16,18],[16,7],[16,3],[18,1],[18,5],
  [17,19],[17,2],[17,6],[19,0],[19,4]];
  
dodecahedron_adjacent_vertices = 
  [11,18,10,10,9,9,8,8,7,11,3,0,5,12,3,0,7,2,1,4];
   
   
icosahedron_vertices = 
  [[0, 1, polyhedraPhi], 
   [0,-1, polyhedraPhi], 
   [0, 1,-polyhedraPhi],
   [0,-1,-polyhedraPhi],
   [ polyhedraPhi,0, 1],
   [ polyhedraPhi,0,-1],
   [-polyhedraPhi,0, 1],
   [-polyhedraPhi,0,-1],
   [ 1, polyhedraPhi,0],
   [-1, polyhedraPhi,0],
   [ 1,-polyhedraPhi,0],
   [-1,-polyhedraPhi,0]]/2;
    
icosahedron_edges = 
  [[0,1],[0,4],[1,4],[0,6],[1,6],  
  [2,3],[2,5],[3,5],[2,7],[3,7],
  [4,5],[4,8],[5,8],[4,10],[5,10],
  [6,7],[6,9],[7,9],[6,11],[7,11],
  [8,9],[8,0],[9,0],[8,2],[9,2],
  [10,11],[10,1],[11,1],[10,3],[11,3]];
  
icosahedron_adjacent_vertices = 
  [1,4,3,5,10,8,9,11,2,7,4,6];
  
  
  
cubeoctahedron_vertices = 
  [[ 1, 1, 0],
   [-1, 1, 0],
   [ 1,-1, 0],
   [-1,-1, 0],
   [ 1, 0, 1],
   [-1, 0, 1],
   [ 1, 0,-1],
   [-1, 0,-1],
   [ 0, 1, 1],
   [ 0,-1, 1],
   [ 0, 1,-1],
   [ 0,-1,-1]]/sqrt(2);
   
cubeoctahedron_edges = 
  [[0,8],[8,1],[1,10],[10,0],
   [2,9],[9,3],[3,11],[11,2],
   [0,4],[4,2],[2,6],[6,0],
   [3,5],[5,1],[1,7],[7,3],
   [8,4],[4,9],[9,5],[5,8], 
   [10,6],[6,11],[11,7],[7,10]];



icosidodecahedron_vertices = 
  [[0, 0, polyhedraPhi],
   [0, 0, -polyhedraPhi],
   [0, polyhedraPhi, 0],
   [0, -polyhedraPhi, 0],
   [polyhedraPhi, 0, 0],
   [-polyhedraPhi, 0, 0],
   [ 1/2, polyhedraPhi/2, polyhedraPhiSq/2],
   [-1/2, polyhedraPhi/2, polyhedraPhiSq/2],
   [ 1/2,-polyhedraPhi/2, polyhedraPhiSq/2],
   [-1/2,-polyhedraPhi/2, polyhedraPhiSq/2],
   [ 1/2, polyhedraPhi/2,-polyhedraPhiSq/2],
   [-1/2, polyhedraPhi/2,-polyhedraPhiSq/2],
   [ 1/2,-polyhedraPhi/2,-polyhedraPhiSq/2],
   [-1/2,-polyhedraPhi/2,-polyhedraPhiSq/2],
   [ polyhedraPhi/2, polyhedraPhiSq/2, 1/2],
   [ polyhedraPhi/2, polyhedraPhiSq/2,-1/2],
   [-polyhedraPhi/2, polyhedraPhiSq/2, 1/2],
   [-polyhedraPhi/2, polyhedraPhiSq/2,-1/2],
   [ polyhedraPhi/2,-polyhedraPhiSq/2, 1/2],
   [ polyhedraPhi/2,-polyhedraPhiSq/2,-1/2],
   [-polyhedraPhi/2,-polyhedraPhiSq/2, 1/2],
   [-polyhedraPhi/2,-polyhedraPhiSq/2,-1/2], 
   [ polyhedraPhiSq/2, 1/2, polyhedraPhi/2],
   [ polyhedraPhiSq/2,-1/2, polyhedraPhi/2],
   [ polyhedraPhiSq/2, 1/2,-polyhedraPhi/2],
   [ polyhedraPhiSq/2,-1/2,-polyhedraPhi/2],
   [-polyhedraPhiSq/2, 1/2, polyhedraPhi/2],
   [-polyhedraPhiSq/2,-1/2, polyhedraPhi/2],
   [-polyhedraPhiSq/2, 1/2,-polyhedraPhi/2],
   [-polyhedraPhiSq/2,-1/2,-polyhedraPhi/2]] /
   sqrt((0-1/2)*(0-1/2) + (0-polyhedraPhi/2)*(0-polyhedraPhi/2) + (polyhedraPhi-polyhedraPhiSq/2)*(polyhedraPhi-polyhedraPhiSq/2));
   
icosidodecahedron_edges = 
  [[4,25],[25,12],[12,13],[13,29],[29,5],[5,26],[26,7],[7,6],[6,22],[22,4],
   [4,23],[23,8],[8,9],[9,27],[27,5],[5,28],[28,11],[11,10],[10,24],[24,4],
   [2,14],[14,22],[22,23],[23,18],[18,3],[3,21],[21,29],[29,28],[28,17],[17,2],
   [2,15],[15,24],[24,25],[25,19],[19,3],[3,20],[20,27],[27,26],[26,16],[16,2],
   [0,6],[6,14],[14,15],[15,10],[10,1],[1,13],[13,21],[21,20],[20,9],[9,0],
   [0,8],[8,18],[18,19],[19,12],[12,1],[1,11],[11,17],[17,16],[16,7],[7,0]];