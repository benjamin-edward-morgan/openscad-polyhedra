
//polyhedra_examples();

module polyhedra_examples() {
    scale(3){
       translate([-5,0,0])
       platonic_solid_examples();
       
       translate([5,0,0]) 
       archimedian_solid_examples();
    }
}

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

module orient_verts(verts,adjacents,n=1,r=0.1) {
    echo(vertices=len(verts));
    for(i=[0:len(verts)-1])
    orient_vertex(verts[i],verts[adjacents[i]])
    //for(i=[0,1])
    //mirror([0,0,i])
    /*
    for(j=[0:n-1])
    rotate(j*360/n)
    linear_extrude(height=3*r,scale=0)
    translate([r/2,0,0])
    circle(r=r/2);
    */
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

//sample_edge(h=1);
module sample_edge(h=2,r=0.03,$fn=16) {
    linear_extrude(height=h,center=true)
        union() {
            circle(r=r);
            //rotate(45)
            //square(size=r);
        }     
} 

module show_edges(verts, edges,r=0.06,$fn=16) {
    echo(edges=len(edges));
    for(i=[0:len(edges)-1]) {
        a = verts[edges[i][0]];
        b = verts[edges[i][1]];        
        
        orient_edge(a,b) {
            //echo(edge_length=norm(a-b));
            sample_edge(h=norm(a-b),r=r);   
        }   
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

//tetrahedron();
module tetrahedron() {
  color("brown")    
  orient_verts(tetrahedron_vertices,tetrahedron_adjacent_vertices,3);  

  color("magenta")
  show_edges(tetrahedron_vertices, tetrahedron_edges); 
    
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
   
tetrahedron_real_adjacent_vertices =
  [[1,2,3],[0,2,3],[0,1,3],[0,1,2]];

tetrahedron_faces = 
  [[0,2,1],[3,0,1],[1,2,3],[3,2,0]];
  
tetrahedron_adjacent_vertices = 
  [1,2,3,1];


//hexahedron();
module hexahedron() {
  color("blue")
  orient_verts(hexahedron_vertices,hexahedron_adjacent_vertices,3);  

  color("green")
  show_edges(hexahedron_vertices, hexahedron_edges);
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
     
hexahedron_adjacent_vertices = 
  [1,3,3,7,5,7,7,6];


//octahedron();
module octahedron() {
  color("orangered")
  orient_verts(octahedron_vertices,octahedron_adjacent_vertices,4); 
    
  color("khaki")
  show_edges(octahedron_vertices, octahedron_edges);  
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
  [2,3,4,4,3,1];

scale(30)
dodecahedron();
module dodecahedron() {
  color("darkorchid")
  orient_verts(dodecahedron_vertices,dodecahedron_adjacent_vertices,3); 
      
  color("lightseagreen")
  show_edges(dodecahedron_vertices, dodecahedron_edges);  
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
  [11,18,10,10,9,9,8,8,7,11,3,0,5,12,3,0,7,2,1,4];
   
   
//icosahedron();
module icosahedron() {
  color("cadetblue")
  orient_verts(icosahedron_vertices,icosahedron_adjacent_vertices,5); 
   
  color("crimson")
  show_edges(icosahedron_vertices, icosahedron_edges);  
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
  [1,4,3,5,10,8,9,11,2,7,4,6];
  
  
//cubeoctahedron();
module cubeoctahedron() {
  color("blueviolet")
  show_verts(cubeoctahedron_vertices);
    
  color("springgreen")
  show_edges(cubeoctahedron_vertices, cubeoctahedron_edges);  
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


//icosidodecahedron();
module icosidodecahedron() {
  color("fuchsia")  
  show_verts(icosidodecahedron_vertices);

  color("green")
  show_edges(icosidodecahedron_vertices, icosidodecahedron_edges);
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
   
   
//truncated_tetrahedron();
module truncated_tetrahedron() {
    color("blue")
    show_verts(truncated_tetrahedron_vertices);
    
    color("green")
    show_edges(truncated_tetrahedron_vertices, truncated_tetrahedron_edges);
}
   
truncated_tetrahedron_vertices = 
[[+3,+1,+1], [+1,+3,+1], [+1,+1,+3],
 [-3,-1,+1], [-1,-3,+1], [-1,-1,+3],
 [-3,+1,-1], [-1,+3,-1], [-1,+1,-3],
 [+3,-1,-1], [+1,-3,-1], [+1,-1,-3]]/sqrt(8);

truncated_tetrahedron_edges = 
[[0,1],[0,2],[1,2],
 [3,4],[3,5],[4,5],
 [9,10],[9,11],[10,11],
 [6,7],[6,8],[7,8],
 [2,5],[4,10],[0,9],[11,8],[6,3],[7,1]];

//truncated_hexahedron();
module truncated_hexahedron() {
    color("blue")
    show_verts(truncated_hexahedron_vertices);
    
    color("green")
    show_edges(truncated_hexahedron_vertices, truncated_hexahedron_edges);
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



//truncated_octahedron();
module truncated_octahedron() {
    color("blue")
    show_verts(truncated_octahedron_vertices);
    
    color("green")
    show_edges(truncated_octahedron_vertices, truncated_octahedron_edges);
    
}

truncated_octahedron_vertices = 
[
[2,1,0],
[2,-1,0],
[2,0,1],
[2,0,-1],
[-2,1,0],
[-2,-1,0],
[-2,0,1],
[-2,0,-1],
[1,2,0],
[-1,2,0],
[0,2,1],
[0,2,-1],
[1,-2,0],
[-1,-2,0],
[0,-2,1],
[0,-2,-1],
[1,0,2],
[-1,0,2],
[0,1,2],
[0,-1,2],
[1,0,-2],
[-1,0,-2],
[0,1,-2],
[0,-1,-2]
] / sqrt(2);

truncated_octahedron_edges = 
[[0,2],[2,1],[1,3],[3,0],
[5,6],[6,4],[4,7],[7,5],
[9,10],[10,8],[8,11],[11,9],
[13,14],[14,12],[12,15],[15,13],
[17,18],[18,16],[16,19],[19,17],
[21,22],[22,20],[20,23],[23,21],
[2,16],[19,14],[17,6],[18,10],
[15,23],[20,3],[22,11],[21,7],
[5,13],[4,9],[8,0],[1,12]
];

//rhombicuboctahedron();
module rhombicuboctahedron() {
    color("blue")
    show_verts(rhombicuboctahedron_vertices);
    
    color("green")
    show_edges(rhombicuboctahedron_vertices, rhombicuboctahedron_edges);
    
}
 

rhombicuboctahedron_vertices = 
[
[ 1, 1, polyhedraR2P1],
[ 1, 1,-polyhedraR2P1],
[ 1,-1, polyhedraR2P1],
[ 1,-1,-polyhedraR2P1],
[-1, 1, polyhedraR2P1],
[-1, 1,-polyhedraR2P1],
[-1,-1, polyhedraR2P1],
[-1,-1,-polyhedraR2P1],

[ 1, polyhedraR2P1, 1],
[ 1, polyhedraR2P1,-1],
[ 1,-polyhedraR2P1, 1],
[ 1,-polyhedraR2P1,-1],
[-1, polyhedraR2P1, 1],
[-1, polyhedraR2P1,-1],
[-1,-polyhedraR2P1, 1],
[-1,-polyhedraR2P1,-1],

[ polyhedraR2P1, 1, 1],
[ polyhedraR2P1, 1,-1],
[ polyhedraR2P1,-1, 1],
[ polyhedraR2P1,-1,-1],
[-polyhedraR2P1, 1, 1],
[-polyhedraR2P1, 1,-1],
[-polyhedraR2P1,-1, 1],
[-polyhedraR2P1,-1,-1],
] / 2;

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

//truncated_cuboctahedron();
module truncated_cuboctahedron() {
    color("blue")
    show_verts(truncated_cuboctahedron_vertices);
    
    
    color("green")
    show_edges(truncated_cuboctahedron_vertices, truncated_cuboctahedron_edges);
    
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
[
[20,21],[21,45],[45,41],[41,17],[17,16],[16,40],[40,44],[44,20],
[8,32],[32,33],[33,9],[9,11],[11,35],[35,34],[34,10],[10,8],
[22,23],[23,47],[47,43],[43,19],[19,18],[18,42],[42,46],[46,22],
[36,37],[37,13],[13,15],[15,39],[39,38],[38,14],[14,12],[12,36],
[0,4],[4,28],[28,30],[30,6],[6,2],[2,26],[26,24],[24,0],
[5,1],[1,25],[25,27],[27,3],[3,7],[7,31],[31,29],[29,5],
[4,44],[20,36],[12,28],
[14,30],[6,46],[22,38],
[2,42],[26,10],[18,34],
[0,40],[16,32],[8,24],
[37,21],[45,5],[29,13],
[27,11],[35,19],[3,43],
[39,23],[7,47],[15,31],
[1,41],[17,33],[25,9]
];

//snub_cube();
module snub_cube() {
    color("blue")
    show_verts(snub_cube_vertices);
    
    color("green")
    show_edges(snub_cube_vertices, snub_cube_edges);
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
[
[13,0],[0,14],[14,3],[3,13],
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
[5,18],[16,4],[6,17],[19,7]
];

