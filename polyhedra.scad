
polyhedra_examples();

module polyhedra_examples() {
    scale(3){
       translate([-5,0,0])
       platonic_solid_examples();
       
       translate([5,0,0]) 
       archimedian_solid_examples();
    }
}

//platonic_solid_examples();
module platonic_solid_examples() {
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
}

module archimedian_solid_examples() {
    
    translate([-3,-4,0])
    truncated_tetrahedron();

    translate([0,-4,0])
    cubeoctahedron();

    translate([3,-4,0])
    truncated_hexahedron();

    translate([-3.5,0,0]) 
    truncated_octahedron();

    translate([0,0,0])
    rhombicuboctahedron();

    translate([4,0,0])
    truncated_cuboctahedron();

    translate([-5,4,0])
    snub_cube();

    translate([0,4,0])
    icosidodecahedron();
    
    /*todo:
    truncated_dodecahedron();
    truncated_icosahedron();
    rhombicosidodecahedron();
    truncated_icosidodecahedron();
    snub_dodecahedron();
    */
   
}

/**********************/
/**Geodesic functions**/
/**********************/
/*
module orient_verts(verts,adjacents,n=1,r=0.1) {
    echo(vertices=len(verts));
    for(i=[0:len(verts)-1])
    orient_vertex(verts[i],verts[adjacents[i]])
    //for(i=[0,1])
    //mirror([0,0,i])
    
    for(j=[0:n-1])
    rotate(j*360/n)
    linear_extrude(height=3*r,scale=0)
    translate([r/2,0,0])
    circle(r=r/2);
    
    //mirror([0,1,0])
    
    //linear_extrude(0.1)
    //text(str(i),font="Consolas",size=0.3,valign="center",halign="center");
    sphere(r=r,$fn=32);
    

}


module show_verts(verts,r=0.1,$fn=32) {
    echo(vertices=len(verts));
    for(i=[0:len(verts)-1])
    translate(verts[i])
    //sphere(r=r);
    linear_extrude(0.1)
    text(str(i),font="Consolas",size=r*2,valign="center",halign="center");
}
*/

module sample_vertex(i,r=0.1) {
    linear_extrude(0.1) {
    text(str(i),font="Consolas",size=r,valign="center",halign="center");
    if(i==6 || i==9)
       translate([0,-r*0.7])
       square(size=[r,r/6],center=true);
    }
}


module show_vertices(verts,adjacents,r=0.1) {
    for(i=[0:len(verts)-1])
    orient_vertex(verts[i], verts[adjacents[i][0]]) 
    sample_vertex(i,r=0.3);

}


//sample_edge(h=1);
module sample_edge(h=2,r=0.03,$fn=16) {
    linear_extrude(height=h,center=true)
        union() {
            circle(r=r);
            rotate(-45)
            square(size=r);
        }     
} 

module show_edges(verts, edges,r=0.03,$fn=16) {
    //echo(edges=len(edges));
    for(i=[0:len(edges)-1]) {
        a = verts[edges[i][0]];
        b = verts[edges[i][1]];        
        
        orient_edge(a,b) {
            sample_edge(h=norm(a-b),r=r);   
        }   
    }
}

//sample_face(i=140,n=3);
module sample_face(i,n,r=3,h=0.1,t=0.1) {
    linear_extrude(height=h) {
        scale(r/20)
        text(str(i),font="Consolas",size=10,valign="center",halign="center");
        rotate(180/n-90)
        difference() {
          circle($fn=n,r=r);
          circle($fn=n,r=r-t);
        }
    }
}

function map_verts(verts, face) = [ for(i=[0:len(face)-1]) verts[face[i]] ];
function sum_verts(verts, i=0, sum=[0,0,0]) = i<len(verts) ? sum_verts(verts, i+1, verts[i] + sum) : sum ;

module show_faces(verts, faces) {
    for(i=[0:len(faces)-1]) {
        center = sum_verts(map_verts(verts,faces[i]))/len(faces[i]) ;
        r = norm(verts[faces[i][0]] - center) * 0.8;
        orient_face(verts, faces[i])
        sample_face(i=i, n=len(faces[i]), r=r); 
    }
}

/*
- a and b are 3-vectors
Transforms a vertial (along z axis) module height of norm(a-b) and centered at the origin such that the ends of the object now lie at positions a and b and such that the x-z plane in the original coordinate system still interects the origin, with the x+ axis facing away from the origin.
*/
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

/*
- a and b are 3-vectors
Transforms a vertical (along z axis) module from the origin to point a such that the z-axis of the original coordinate system still intersects the origin, and that the x-axis of the original coordinate system lies in the plane formed by a, b and the origin.
*/
module orient_vertex(a,b) {
  what = a/norm(a);    
  vhat = cross(b,a)/norm(cross(b,a));
  uhat = -cross(what,vhat);
    
  mat = 
  [[uhat[0],vhat[0],what[0],a[0]],
   [uhat[1],vhat[1],what[1],a[1]],
   [uhat[2],vhat[2],what[2],a[2]],  
   [0,0,0,1]];
   
  multmatrix(mat)
    children();  
}

module orient_face(verts, face) {
    u = verts[face[0]] - verts[face[1]] ;
    uhat = u/norm(u);
    q = verts[face[1]] - verts[face[2]] ;
    w = cross(q,u);
    what = w/norm(w);
    vhat = cross(what,uhat);
    
    center = sum_verts(map_verts(verts,face))/len(face) ;

    mat = 
      [[uhat[0],vhat[0],what[0],center[0]],
       [uhat[1],vhat[1],what[1],center[1]],
       [uhat[2],vhat[2],what[2],center[2]],  
       [0,0,0,1]];
    
    multmatrix(mat)
       children();
}


/*************/
/**Constants**/
/*************/
polyhedraPhi = (1 + sqrt(5))/2;
polyhedraPhiSq = polyhedraPhi*polyhedraPhi;
polyhedraZeta = sqrt(2)-1;
polyhedraR2P1 = sqrt(2)+1;
polyhedra2R2P1 = 2*sqrt(2)+1;
polyhedraTribConst = 1.839286755214161;
polyhedraSnubCubeBeta = pow(26+6*sqrt(33), 1/3);
polyhedraSnubCubeAlpha = sqrt(4/3-16/3/polyhedraSnubCubeBeta+2*polyhedraSnubCubeBeta/3);

/**********************/
/**Polyhedra examples**/
/**********************/

//scale(30)
//tetrahedron();
module tetrahedron() {
  color("brown")    
  show_vertices(tetrahedron_vertices,tetrahedron_adjacent_vertices,3);  

  color("magenta")
  show_edges(tetrahedron_vertices, tetrahedron_edges); 
    
  color("orange")
  show_faces(tetrahedron_vertices, tetrahedron_faces);
    
  color("green")
  scale(0.5)
  polyhedron(points=tetrahedron_vertices,faces=tetrahedron_faces);
    
}

tetrahedron_vertices =
  [[1,1,1],
   [1,-1,-1],
   [-1,1,-1],
   [-1,-1,1]]/sqrt(8);

tetrahedron_edges =
  [[0,1],[1,2],[0,2],
   [2,3],[1,3],[0,3]];
   
tetrahedron_adjacent_vertices =
  [[1,2,3],[0,2,3],[0,1,3],[0,1,2]];

tetrahedron_faces = 
  [[0,2,1],[3,0,1],[1,2,3],[3,2,0]];
  

//scale(30)
//hexahedron();
module hexahedron() {
  color("blue")
  show_vertices(hexahedron_vertices,hexahedron_adjacent_vertices,3);  

  color("green")
  show_edges(hexahedron_vertices, hexahedron_edges);
    
  color("orange")
  show_faces(hexahedron_vertices, hexahedron_faces);
    
  color("tomato")
  scale(0.5)
  polyhedron(points=hexahedron_vertices,faces=hexahedron_faces);
    
}

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

hexahedron_faces = 
 [[2,6,4,0],
  [3,7,6,2],
  [1,5,7,3],
  [0,4,5,1],
  [6,7,5,4],
  [3,2,0,1],
  ];
     
hexahedron_adjacent_vertices = 
    [[1,2,4],
    [0,5,3],
    [0,6,3],
    [1,2,7],
    [0,5,6],
    [1,7,4],
    [2,7,4],
    [5,6,3]];

//scale(30)
//octahedron();
module octahedron() {
  color("orangered")
  show_vertices(octahedron_vertices,octahedron_adjacent_vertices,4); 
    
  color("khaki")
  show_edges(octahedron_vertices, octahedron_edges);  
    
  color("rebeccapurple")  
  show_faces(octahedron_vertices, octahedron_faces);
    
  color("peachpuff")
  scale(0.5)  
  polyhedron(points=octahedron_vertices,faces=octahedron_faces);
}

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
    [[5,2,3,4],
    [5,2,3,4],
    [0,1,5,4],
    [0,1,5,4],
    [0,1,2,3],
    [0,1,2,3]];
    
octahedron_faces = 
[[2,4,1],
[1,4,3],
[3,4,0],
[0,4,2],
[5,0,2],
[5,2,1],
[5,1,3],
[5,3,0]];

//scale(30)
//dodecahedron();
module dodecahedron() {
  color("darkorchid")
  show_vertices(dodecahedron_vertices,dodecahedron_adjacent_vertices,3); 
      
  color("lightseagreen")
  show_edges(dodecahedron_vertices, dodecahedron_edges);  
    
  color("gold")
  show_faces(dodecahedron_vertices, dodecahedron_faces);
    
  color("crimson")
  scale(0.5)
  polyhedron(points=dodecahedron_vertices, faces=dodecahedron_faces);
}

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
[[15,19,11],[18,14,11],[15,17,10],[16,10,14],
[9,19,13],[12,9,18],[13,17,8],[12,16,8],[6,10,7],
[5,4,11],[2,3,8],[0,9,1],[13,5,7],[12,6,4],
[15,1,3],[0,2,14],[3,18,7],[19,2,6],
[1,16,5],[0,17,4]];

dodecahedron_faces = 
[[16,18,5,12,7],
[3,16,7,8,10],
[2,10,8,6,17],
[17,6,13,4,19],
[4,13,12,5,9],
[13,6,8,7,12],
[10,2,15,14,3],
[3,14,1,18,16],
[18,1,11,9,5],
[9,11,0,19,4],
[19,0,15,2,17],
[11,1,14,15,0]];
   
//scale(30)   
//icosahedron();
module icosahedron() {
  color("cadetblue")
  show_vertices(icosahedron_vertices,icosahedron_adjacent_vertices,5); 
   
  color("crimson")
  show_edges(icosahedron_vertices, icosahedron_edges);  
    
  color("mediumseagreen")
  show_faces(icosahedron_vertices, icosahedron_faces);
    
  color("lemonchiffon")
  scale(0.75)
  polyhedron(points=icosahedron_vertices, faces=icosahedron_faces);
}
   
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
[[1,6,9,8,4],[0,10,6,11,4],[5,9,7,3,8],[5,10,2,7,11],
[0,5,10,1,8],[10,2,3,8,4],[0,1,9,7,11],[6,9,2,3,11],
[0,5,9,2,4],[0,6,2,7,8],[5,1,3,11,4],[10,1,6,7,3]];

icosahedron_faces =
[[8,4,0],[8,0,9],[9,0,6],[6,0,1],[1,0,4],
[11,1,10],[10,1,4],[10,4,5],[5,4,8],[5,8,2],
[2,8,9],[2,9,7],[7,9,6],[7,6,11],[11,6,1],
[11,3,7],[10,3,11],[5,3,10],[5,2,3],[2,7,3]];
  
  
//cubeoctahedron();
module cubeoctahedron() {
  color("blueviolet")
  show_vertices(cubeoctahedron_vertices, cubeoctahedron_adjacent_vertices);
    
  color("springgreen")
  show_edges(cubeoctahedron_vertices, cubeoctahedron_edges);  
    
  color("magenta")
  show_faces(cubeoctahedron_vertices, cubeoctahedron_square_faces);
    
  color("navy")
  show_faces(cubeoctahedron_vertices, cubeoctahedron_triangle_faces);
    
  color("papayawhip")
  scale(0.8)
  polyhedron(points = cubeoctahedron_vertices, faces = cubeoctahedron_faces);  
    
}
  
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

cubeoctahedron_adjacent_vertices = 
[[6,10,4,8],[5,10,7,8],[9,6,4,11],
[9,5,7,11],[0,9,2,8],[9,1,3,8],
[0,2,10,11],[1,3,10,11],[0,1,5,4],
[5,2,3,4],[0,1,6,7],[2,6,3,7]];

cubeoctahedron_square_faces = 
[[4,9,5,8],[11,3,9,2],[6,2,4,0],
[10,0,8,1],[7,1,5,3],[7,11,6,10]];

cubeoctahedron_triangle_faces = 
[[7,10,1],[10,6,0],[2,6,11],[11,7,3],
[5,1,8],[8,0,4],[4,2,9],[9,3,5]];

cubeoctahedron_faces = concat(cubeoctahedron_square_faces, cubeoctahedron_triangle_faces);

//scale(30)
//icosidodecahedron();
module icosidodecahedron() {
  color("forestgreen")  
  show_vertices(icosidodecahedron_vertices, icosidodecahedron_adjacent_vertices);

  color("palegreen")
  show_edges(icosidodecahedron_vertices, icosidodecahedron_edges);
    
  color("yellow")
  show_faces(icosidodecahedron_vertices, icosidodecahedron_triangle_faces);
    
  color("magenta")
  show_faces(icosidodecahedron_vertices, icosidodecahedron_pentagon_faces);
    
  color("darkslateblue")
  scale(0.9)  
  polyhedron(points=icosidodecahedron_vertices, faces = icosidodecahedron_faces);
}

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
   
icosidodecahedron_adjacent_vertices = 
[[9,6,7,8],[12,13,10,11],[15,16,17,14],[19,20,21,18],[24,25,22,23],
[27,28,29,26],[0,7,22,14],[0,16,6,26],[0,9,18,23],[0,27,20,8],
[15,1,24,11],[1,17,28,10],[19,1,13,25],[12,1,21,29],[15,2,6,22],
[2,24,10,14],[2,17,7,26],[16,2,28,11],[19,3,8,23],[12,3,18,25],
[27,9,3,21],[13,20,3,29],[6,4,14,23],[18,4,22,8],[15,10,25,4],
[12,19,24,4],[27,16,5,7],[9,5,20,26],[5,17,11,29],[13,5,21,28]];
   
   
icosidodecahedron_triangle_faces = 
[[6,0,7],[22,6,14],[16,7,26],[5,26,27],
[28,5,29],[13,29,21],[1,13,12],[12,19,25],
[25,4,24],[4,23,22],[0,8,9],[9,20,27],
[20,3,21],[3,18,19],[18,8,23],[15,14,2],
[2,16,17],[11,17,28],[10,11,1],[24,15,10]];

icosidodecahedron_pentagon_faces = 
[[17,16,26,5,28],[14,6,7,16,2],[26,7,0,9,27],
[20,9,8,18,3],[0,6,22,23,8],[27,20,21,29,5],
[21,3,19,12,13],[19,18,23,4,25],[4,22,14,15,24],
[10,15,2,17,11],[1,11,28,29,13],[10,1,12,25,24]];

icosidodecahedron_faces = concat(icosidodecahedron_triangle_faces, icosidodecahedron_pentagon_faces);
   
   
   
//truncated_tetrahedron();
module truncated_tetrahedron() {
    color("blue")
    show_vertices(truncated_tetrahedron_vertices, truncated_tetrahedron_adjacent_vertices);
    
    color("green")
    show_edges(truncated_tetrahedron_vertices, truncated_tetrahedron_edges);
    
    color("yellow")
    show_faces(truncated_tetrahedron_vertices, truncated_tetrahedron_triangle_faces);
    
    color("red")
    show_faces(truncated_tetrahedron_vertices, truncated_tetrahedron_hexagon_faces);
    
    color("white")
    scale(0.8)
    polyhedron(points=truncated_tetrahedron_vertices, faces=truncated_tetrahedron_faces);
}
   
truncated_tetrahedron_vertices = 
[[+3,+1,+1], [+1,+3,+1], [+1,+1,+3],
 [-3,-1,+1], [-1,-3,+1], [-1,-1,+3],
 [-3,+1,-1], [-1,+3,-1], [-1,+1,-3],
 [+3,-1,-1], [+1,-3,-1], [+1,-1,-3]]/sqrt(8);

truncated_tetrahedron_edges = 
[[0,1],[0,2],[1,2],[3,4],[3,5],[4,5],
 [9,10],[9,11],[10,11],[6,7],[6,8],[7,8],
 [2,5],[4,10],[0,9],[11,8],[6,3],[7,1]];

truncated_tetrahedron_adjacent_vertices = 
[[9,1,2],[0,2,7],[0,1,5],[5,6,4],
[5,3,10],[2,3,4],[3,7,8],[1,6,8],
[6,7,11],[0,10,11],[9,4,11],[9,10,8]];

truncated_tetrahedron_triangle_faces = 
[[0,2,1],[3,5,4],[10,9,11],[7,6,8]];

truncated_tetrahedron_hexagon_faces = 
[[8,6,3,4,10,11],[1,2,5,3,6,7],
[9,0,1,7,8,11],[10,4,5,2,0,9]];

truncated_tetrahedron_faces = 
concat(truncated_tetrahedron_triangle_faces, truncated_tetrahedron_hexagon_faces);

//truncated_hexahedron();
module truncated_hexahedron() {
    color("blue")
    show_vertices(truncated_hexahedron_vertices, truncated_hexahedron_adjacent_vertices);
    
    color("green")
    show_edges(truncated_hexahedron_vertices, truncated_hexahedron_edges);
    
    color("yellow")
    show_faces(truncated_hexahedron_vertices, truncated_hexahedron_triangle_faces);
    
    color("red")
    show_faces(truncated_hexahedron_vertices, truncated_hexahedron_octagon_faces);
    
    color("white")
    scale(0.8)
    polyhedron(points = truncated_hexahedron_vertices, faces = truncated_hexahedron_octagon_faces);
}

truncated_hexahedron_vertices = 
[[ polyhedraZeta, 1, 1],
[ polyhedraZeta, 1,-1],
[ polyhedraZeta,-1, 1],
[ polyhedraZeta,-1,-1],
[-polyhedraZeta, 1, 1],
[-polyhedraZeta, 1,-1],
[-polyhedraZeta,-1, 1],
[-polyhedraZeta,-1,-1],
[ 1, polyhedraZeta, 1],
[ 1, polyhedraZeta,-1],
[ 1,-polyhedraZeta, 1],
[ 1,-polyhedraZeta,-1],
[-1, polyhedraZeta, 1],
[-1, polyhedraZeta,-1],
[-1,-polyhedraZeta, 1],
[-1,-polyhedraZeta,-1],
[ 1, 1, polyhedraZeta],
[ 1, 1,-polyhedraZeta],
[ 1,-1, polyhedraZeta],
[ 1,-1,-polyhedraZeta],
[-1, 1, polyhedraZeta],
[-1, 1,-polyhedraZeta],
[-1,-1, polyhedraZeta],
[-1,-1,-polyhedraZeta]];

truncated_hexahedron_edges = 
[[2,10],[2,18],[10,18],
[0,8],[0,16],[8,16],
[4,20],[4,12],[12,20],
[6,14],[6,22],[14,22],
[3,11],[3,19],[11,19],
[7,15],[7,23],[15,23],
[5,13],[5,21],[13,21],
[1,17],[1,9],[9,17],
[17,16],[8,10],[18,19],[9,11],
[14,12],[20,21],[13,15],[22,23],
[6,2],[7,3],[1,5],[0,4]];

truncated_hexahedron_adjacent_vertices = 
[[16,4,8],[9,5,17],[6,18,10],[19,7,11],
[0,12,20],[1,13,21],[2,22,14],[15,3,23],
[0,16,10],[1,17,11],[2,18,8],[9,19,3],
[20,4,14],[15,5,21],[12,6,22],[13,7,23],
[0,17,8],[9,1,16],[19,2,10],[3,18,11],
[12,21,4],[13,5,20],[6,14,23],[15,7,22]];

truncated_hexahedron_triangle_faces = 
[[16,8,0],[20,4,12],[22,14,6],[2,10,18],
[19,11,3],[9,17,1],[5,21,13],[15,23,7]];

truncated_hexahedron_octagon_faces = 
[[23,22,6,2,18,19,3,7],
[19,18,10,8,16,17,9,11],
[17,16,0,4,20,21,5,1],
[21,20,12,14,22,23,15,13],
[0,8,10,2,6,14,12,4],
[13,15,7,3,11,9,1,5]];

truncated_hexahedron_faces = 
concat(truncated_hexahedron_triangle_faces, truncated_hexahedron_octagon_faces);

//truncated_octahedron();
module truncated_octahedron() {
    color("blue")
    show_vertices(truncated_octahedron_vertices,truncated_octahedron_adjacent_vertices);
    
    color("green")
    show_edges(truncated_octahedron_vertices, truncated_octahedron_edges);
    
    color("yellow")
    show_faces(truncated_octahedron_vertices, truncated_octahedron_square_faces);
    
    color("red")
    show_faces(truncated_octahedron_vertices, truncated_octahedron_hexagon_faces);
    
    color("white")
    scale(0.9)
    polyhedron(points = truncated_octahedron_vertices, faces = truncated_octahedron_faces);
    
}

truncated_octahedron_vertices = 
[[2,1,0],[2,-1,0],[2,0,1],[2,0,-1],
[-2,1,0],[-2,-1,0],[-2,0,1],[-2,0,-1],
[1,2,0],[-1,2,0],[0,2,1],[0,2,-1],
[1,-2,0],[-1,-2,0],[0,-2,1],[0,-2,-1],
[1,0,2],[-1,0,2],[0,1,2],[0,-1,2],
[1,0,-2],[-1,0,-2],[0,1,-2],[0,-1,-2]] / sqrt(2);

truncated_octahedron_edges = 
[[0,2],[2,1],[1,3],[3,0],
[5,6],[6,4],[4,7],[7,5],
[9,10],[10,8],[8,11],[11,9],
[13,14],[14,12],[12,15],[15,13],
[17,18],[18,16],[16,19],[19,17],
[21,22],[22,20],[20,23],[23,21],
[2,16],[19,14],[17,6],[18,10],
[15,23],[20,3],[22,11],[21,7],
[5,13],[4,9],[8,0],[1,12]];

truncated_octahedron_adjacent_vertices = 
[[2,3,8],[12,2,3],[0,1,16],[0,1,20],
[9,6,7],[13,6,7],[5,17,4],[5,21,4],
[0,10,11],[10,4,11],[9,18,8],[9,22,8],
[15,1,14],[15,5,14],[12,19,13],[12,13,23],
[19,2,18],[19,6,18],[16,17,10],[16,17,14],
[3,22,23],[7,22,23],[20,21,11],[15,20,21]];

truncated_octahedron_square_faces = 
[[18,16,19,17],[4,6,5,7],[13,14,12,15],
[1,2,0,3],[8,10,9,11],[20,22,21,23]];

truncated_octahedron_hexagon_faces = 
[[11,22,20,3,0,8],[3,20,23,15,12,1],
[15,23,21,7,5,13],[7,21,22,11,9,4],
[2,1,12,14,19,16],[14,13,5,6,17,19],
[6,4,9,10,18,17],[10,8,0,2,16,18]];

truncated_octahedron_faces = 
concat(truncated_octahedron_square_faces, truncated_octahedron_hexagon_faces);

//rhombicuboctahedron();
module rhombicuboctahedron() {
    color("blue")
    show_vertices(rhombicuboctahedron_vertices, rhombicuboctahedron_adjacent_vertices);
    
    color("green")
    show_edges(rhombicuboctahedron_vertices, rhombicuboctahedron_edges);
    
    color("yellow")
    show_faces(rhombicuboctahedron_vertices, rhombicuboctahedron_triangle_faces);
    
    color("red")
    show_faces(rhombicuboctahedron_vertices, rhombicuboctahedron_square_faces);
    
    color("white")
    scale(0.9)
    polyhedron(rhombicuboctahedron_vertices, rhombicuboctahedron_faces);
}
 
rhombicuboctahedron_vertices = 
[
[ 1, 1, polyhedraR2P1],[ 1, 1,-polyhedraR2P1],[ 1,-1, polyhedraR2P1],[ 1,-1,-polyhedraR2P1],
[-1, 1, polyhedraR2P1],[-1, 1,-polyhedraR2P1],[-1,-1, polyhedraR2P1],[-1,-1,-polyhedraR2P1],
[ 1, polyhedraR2P1, 1],[ 1, polyhedraR2P1,-1],[ 1,-polyhedraR2P1, 1],[ 1,-polyhedraR2P1,-1],
[-1, polyhedraR2P1, 1],[-1, polyhedraR2P1,-1],[-1,-polyhedraR2P1, 1],[-1,-polyhedraR2P1,-1],
[ polyhedraR2P1, 1, 1],[ polyhedraR2P1, 1,-1],[ polyhedraR2P1,-1, 1],[ polyhedraR2P1,-1,-1],
[-polyhedraR2P1, 1, 1],[-polyhedraR2P1, 1,-1],[-polyhedraR2P1,-1, 1],[-polyhedraR2P1,-1,-1],] / 2;

rhombicuboctahedron_edges = 
[
[3,19],[19,11],[11,3],
[1,9],[9,17],[17,1],
[5,13],[13,21],[21,5],
[7,15],[15,23],[23,7],
[2,10],[10,18],[18,2],
[0,8],[8,16],[16,0],
[4,12],[12,20],[20,4],
[6,14],[14,22],[22,6],
[6,4],[4,0],[0,2],[2,6],
[10,11],[11,15],[15,14],[14,10],
[17,19],[19,18],[18,16],[16,17],
[8,9],[9,13],[13,12],[12,8],
[20,21],[21,23],[23,22],[22,20],
[1,3],[3,7],[7,5],[5,1]
];

rhombicuboctahedron_adjacent_vertices = 
[[16,2,4,8],[9,5,17,3],[0,6,18,10],[19,1,7,11],
[0,12,20,6],[1,13,21,7],[2,22,4,14],[15,5,3,23],
[0,12,9,16],[1,13,17,8],[2,18,14,11],[15,19,3,10],
[13,20,4,8],[12,9,5,21],[15,6,10,22],[7,14,11,23],
[0,17,18,8],[9,1,19,16],[19,16,2,10],[17,3,18,11],
[12,21,4,22],[13,5,20,23],[20,6,14,23],[15,21,7,22]];

rhombicuboctahedron_triangle_faces = 
[[10,2,18],[16,0,8],[12,4,20],[22,6,14],
[3,11,19],[1,17,9],[5,13,21],[7,23,15]];

rhombicuboctahedron_square_faces = 
[[0,2,6,4],[20,4,6,22],[14,6,2,10],
[18,2,0,16],[8,0,4,12],[17,16,8,9],
[9,8,12,13],[13,12,20,21],[21,20,22,23],
[23,22,14,15],[15,14,10,11],[11,10,18,19],
[19,18,16,17],[1,3,19,17],[1,9,13,5],
[5,21,23,7],[7,15,11,3],[7,3,1,5]];

rhombicuboctahedron_faces = 
concat(rhombicuboctahedron_triangle_faces, rhombicuboctahedron_square_faces);

//scale(30)
//truncated_cuboctahedron();
module truncated_cuboctahedron() {
    color("blue")
    show_vertices(truncated_cuboctahedron_vertices, truncated_cuboctahedron_adjacent_vertices);
    
    color("green")
    show_edges(truncated_cuboctahedron_vertices, truncated_cuboctahedron_edges);
    
    color("yellow")
    show_faces(truncated_cuboctahedron_vertices, truncated_cuboctahedron_square_faces);
    
    color("red")
    show_faces(truncated_cuboctahedron_vertices, truncated_cuboctahedron_hexagon_faces);
    
    color("darkmagenta")
    show_faces(truncated_cuboctahedron_vertices, truncated_cuboctahedron_octagon_faces);
    
    color("white")
    scale(0.9)
    polyhedron(points = truncated_cuboctahedron_vertices, faces = truncated_cuboctahedron_faces);
}

truncated_cuboctahedron_vertices = 
[
[ 1, polyhedraR2P1, polyhedra2R2P1],
[ 1, polyhedraR2P1,-polyhedra2R2P1],
[ 1,-polyhedraR2P1, polyhedra2R2P1],
[ 1,-polyhedraR2P1,-polyhedra2R2P1],
[-1, polyhedraR2P1, polyhedra2R2P1],
[-1, polyhedraR2P1,-polyhedra2R2P1],
[-1,-polyhedraR2P1, polyhedra2R2P1],
[-1,-polyhedraR2P1,-polyhedra2R2P1],
[ polyhedra2R2P1, 1, polyhedraR2P1],
[ polyhedra2R2P1, 1,-polyhedraR2P1],
[ polyhedra2R2P1,-1, polyhedraR2P1],
[ polyhedra2R2P1,-1,-polyhedraR2P1],
[-polyhedra2R2P1, 1, polyhedraR2P1],
[-polyhedra2R2P1, 1,-polyhedraR2P1],
[-polyhedra2R2P1,-1, polyhedraR2P1],
[-polyhedra2R2P1,-1,-polyhedraR2P1],
[ polyhedraR2P1, polyhedra2R2P1, 1],
[ polyhedraR2P1, polyhedra2R2P1,-1],
[ polyhedraR2P1,-polyhedra2R2P1, 1],
[ polyhedraR2P1,-polyhedra2R2P1,-1],
[-polyhedraR2P1, polyhedra2R2P1, 1],
[-polyhedraR2P1, polyhedra2R2P1,-1],
[-polyhedraR2P1,-polyhedra2R2P1, 1],
[-polyhedraR2P1,-polyhedra2R2P1,-1],
[ polyhedraR2P1, 1, polyhedra2R2P1],
[ polyhedraR2P1, 1,-polyhedra2R2P1],
[ polyhedraR2P1,-1, polyhedra2R2P1],
[ polyhedraR2P1,-1,-polyhedra2R2P1],
[-polyhedraR2P1, 1, polyhedra2R2P1],
[-polyhedraR2P1, 1,-polyhedra2R2P1],
[-polyhedraR2P1,-1, polyhedra2R2P1],
[-polyhedraR2P1,-1,-polyhedra2R2P1],
[ polyhedra2R2P1, polyhedraR2P1, 1],
[ polyhedra2R2P1, polyhedraR2P1,-1],
[ polyhedra2R2P1,-polyhedraR2P1, 1],
[ polyhedra2R2P1,-polyhedraR2P1,-1],
[-polyhedra2R2P1, polyhedraR2P1, 1],
[-polyhedra2R2P1, polyhedraR2P1,-1],
[-polyhedra2R2P1,-polyhedraR2P1, 1],
[-polyhedra2R2P1,-polyhedraR2P1,-1],
[ 1, polyhedra2R2P1, polyhedraR2P1],
[ 1, polyhedra2R2P1,-polyhedraR2P1],
[ 1,-polyhedra2R2P1, polyhedraR2P1],
[ 1,-polyhedra2R2P1,-polyhedraR2P1],
[-1, polyhedra2R2P1, polyhedraR2P1],
[-1, polyhedra2R2P1,-polyhedraR2P1],
[-1,-polyhedra2R2P1, polyhedraR2P1],
[-1,-polyhedra2R2P1,-polyhedraR2P1]
]/2;

truncated_cuboctahedron_edges = 
[[20,21],[21,45],[45,41],[41,17],[17,16],[16,40],[40,44],[44,20],
[8,32],[32,33],[33,9],[9,11],[11,35],[35,34],[34,10],[10,8],
[22,23],[23,47],[47,43],[43,19],[19,18],[18,42],[42,46],[46,22],
[36,37],[37,13],[13,15],[15,39],[39,38],[38,14],[14,12],[12,36],
[0,4],[4,28],[28,30],[30,6],[6,2],[2,26],[26,24],[24,0],
[5,1],[1,25],[25,27],[27,3],[3,7],[7,31],[31,29],[29,5],
[4,44],[20,36],[12,28],[14,30],[6,46],[22,38],
[2,42],[26,10],[18,34],[0,40],[16,32],[8,24],
[37,21],[45,5],[29,13],[27,11],[35,19],[3,43],
[39,23],[7,47],[15,31],[1,41],[17,33],[25,9]];

truncated_cuboctahedron_adjacent_vertices = 
[[24,4,40],[5,25,41],[6,42,26],[27,7,43],[0,28,44],
[45,1,29],[30,46,2],[31,3,47],[32,24,10],[33,25,11],
[34,8,26],[9,27,35],[36,28,14],[15,37,29],[12,30,38],
[13,31,39],[17,32,40],[33,16,41],[19,34,42],[35,18,43],
[21,36,44],[45,37,20],[46,38,23],[39,22,47],[0,26,8],
[27,9,1],[2,24,10],[3,25,11],[30,12,4],[31,13,5],
[6,28,14],[15,7,29],[33,16,8],[9,17,32],[35,18,10],
[19,34,11],[12,37,20],[13,21,36],[39,22,14],[15,38,23],
[0,16,44],[45,1,17],[46,2,18],[19,3,47],[20,40,4],
[5,21,41],[42,6,22],[43,7,23]];

truncated_cuboctahedron_square_faces = 
[[40,0,4,44],[12,28,30,14],[46,6,2,42],[10,26,24,8],
[32,16,17,33],[20,36,37,21],[39,38,22,23],[18,34,35,19],
[11,9,25,27],[1,41,45,5],[29,13,15,31],[7,47,43,3]];

truncated_cuboctahedron_hexagon_faces = 
[[38,14,30,6,46,22],[42,2,26,10,34,18],
[32,8,24,0,40,16],[44,4,28,12,36,20],
[31,15,39,23,47,7],[3,43,19,35,11,27],
[9,33,17,41,1,25],[5,45,21,37,13,29]];

truncated_cuboctahedron_octagon_faces = 
[[4,0,24,26,2,6,30,28],[37,36,12,14,38,39,15,13],
[42,18,19,43,47,23,22,46],[11,35,34,10,8,32,33,9],
[21,45,41,17,16,40,44,20],[29,31,7,3,27,25,1,5]];

truncated_cuboctahedron_faces = 
concat(truncated_cuboctahedron_square_faces, truncated_cuboctahedron_hexagon_faces, truncated_cuboctahedron_octagon_faces);


//snub_cube();
module snub_cube() {
    color("blue")
    show_vertices(snub_cube_vertices, snub_cube_adjacent_vertices);
    
    color("green")
    show_edges(snub_cube_vertices, snub_cube_edges);
    
    color("yellow")
    show_faces(snub_cube_vertices, snub_cube_triangle_faces);
    
    color("red")
    show_faces(snub_cube_vertices, snub_cube_square_faces);
    
    color("white")
    scale(0.9)
    polyhedron(points = snub_cube_vertices, faces = snub_cube_faces);
}

snub_cube_vertices = 
[
[ 1, 1/polyhedraTribConst, polyhedraTribConst],
[ 1,-1/polyhedraTribConst,-polyhedraTribConst],
[-1, 1/polyhedraTribConst,-polyhedraTribConst],
[-1,-1/polyhedraTribConst, polyhedraTribConst],
[ polyhedraTribConst, 1, 1/polyhedraTribConst],
[ polyhedraTribConst,-1,-1/polyhedraTribConst],
[-polyhedraTribConst, 1,-1/polyhedraTribConst],
[-polyhedraTribConst,-1, 1/polyhedraTribConst],
[ 1/polyhedraTribConst, polyhedraTribConst, 1],
[ 1/polyhedraTribConst,-polyhedraTribConst,-1],
[-1/polyhedraTribConst, polyhedraTribConst,-1],
[-1/polyhedraTribConst,-polyhedraTribConst, 1],
[ 1/polyhedraTribConst, 1,-polyhedraTribConst],
[-1/polyhedraTribConst, 1, polyhedraTribConst],
[ 1/polyhedraTribConst,-1, polyhedraTribConst],
[-1/polyhedraTribConst,-1,-polyhedraTribConst],
[ 1, polyhedraTribConst,-1/polyhedraTribConst],
[-1, polyhedraTribConst, 1/polyhedraTribConst],
[ 1,-polyhedraTribConst, 1/polyhedraTribConst],
[-1,-polyhedraTribConst,-1/polyhedraTribConst],
[ polyhedraTribConst, 1/polyhedraTribConst,-1],
[-polyhedraTribConst, 1/polyhedraTribConst, 1],
[ polyhedraTribConst,-1/polyhedraTribConst, 1],
[-polyhedraTribConst,-1/polyhedraTribConst,-1]
]/polyhedraSnubCubeAlpha;
//7:23,21,3,
snub_cube_edges = 
[[13,0],[0,14],[14,3],[3,13],
[4,20],[20,5],[5,22],[22,4],
[8,16],[16,10],[10,17],[17,8],
[7,23],[23,6],[6,21],[21,7],
[9,18],[18,11],[11,19],[19,9],
[1,12],[12,2],[2,15],[15,1],
[14,22],[22,0],[0,4],[4,8],[8,0],
[8,13],[13,17],[17,21],[21,13],
[21,3],[3,7],[7,11],[11,3],
[11,14],[14,18],[18,22],
[1,9],[9,15],[15,19],[19,23],[23,15],
[23,2],[2,6],[6,10],[10,2],
[10,12],[12,16],[16,20],[20,12],
[20,1],[1,5],[1,9],[9,5],
[5,18],[16,4],[6,17],[19,7]];

snub_cube_adjacent_vertices = 
[[14,13,22,8,4],[5,20,9,12,15],[10,6,12,23,15],
[14,21,13,7,11],[0,20,22,16,8],[20,1,9,22,18],
[10,21,2,17,23],[21,3,11,23,19],[0,13,17,16,4],
[5,1,18,19,15],[6,2,17,12,16],[14,7,3,18,19],
[10,20,1,2,16],[0,21,17,3,8],[0,22,3,18,11],
[1,9,2,23,19],[10,20,12,8,4],[10,6,21,13,8],
[5,14,9,22,11],[9,7,11,23,15],[5,1,12,16,4],
[6,13,17,7,3],[0,5,14,18,4],[6,2,7,19,15]];

snub_cube_triangle_faces = 
[[22,14,0],[22,0,4],[4,0,8],[8,0,13],
[17,8,13],[17,13,21],[21,13,3],[7,21,3],
[7,3,11],[11,3,14],[18,11,14],[18,14,22],
[5,18,22],[20,4,16],[16,4,8],[10,17,6],
[6,17,21],[23,7,19],[19,7,11],[9,18,5],
[20,16,12],[12,16,10],[2,10,6],[2,6,23],
[12,10,2],[2,23,15],[15,23,19],[15,19,9],
[15,9,1],[1,9,5],[1,5,20],[1,20,12]];

snub_cube_square_faces = 
[[0,14,3,13],[16,8,17,10],[6,21,7,23],
[19,11,18,9],[5,22,4,20],[1,12,2,15]];

snub_cube_faces = 
concat(snub_cube_triangle_faces, snub_cube_square_faces);
