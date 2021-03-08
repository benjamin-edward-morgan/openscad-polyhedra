/*

To the extent possible under law, Benjamin E Morgan has waived all copyright and related or neighboring rights to openscad-polyhedra. This work is published in the public domain.
Original Source: https://github.com/benjamin-edward-morgan/openscad-polyhedra

The arrays and utility functions included here can be used to place modules coincident with the vertices, edges and faces of the Platonic and Archimedean solids.

All polyhedra are centered at the origin and have an edge length of 1.

Included polyhedra:
- tetrahedron
- octahedron
- hexahedron
- icosahedron
- dodecahedron
- cubeoctahedron
- truncated_tetrahedron
- snub_cube
- rhombicuboctahedron
- truncated_hexahedron
- truncated_octahedron
- icosidodecahedron
- snub_dodecahedron
- rhombicosidodecahedron
- truncated_cuboctahedron
- truncated_icosahedron
- truncated_dodecahedron
- truncated_icosidodecahedron

Each shape includes an array of vertices, edges, adjacent_vertices, and faces.

Archimedean solids also include separate arrays of faces that are of the same polygon shape.

Example:
- snub_dodecahedron_vertices - an array of 3-vectors
- snub_dodecahedron_edges - an array of 2-tuples containing indexes into the vertices array, one tuple for each edge.
- snub_dodecahedron_adjacent_vertices - an array of arrays, each containing indexes into the vertex array. For example, snub_dodecahedron_adjacent_vertices[3] is an array containing the indexes of vertices that are connected to snub_dodecahedron_vertices[3] by an edge
- snub_dodecahedron_triangle_faces and snub_dodecahedron_pentagon_faces contain arrays with indices in the vertex array for each triangular and pentagonal face, respectively
- snub_dodecahedron_faces contains all faces

Usage:
// add polyhedra.scad to your project and include it
include<polyhedra.scad>;

// to arrange modules at vertices
for(i=[0:len(snub_dodecahedron_vertices)-1])
    orient_vertex(
        snub_dodecahedron_vertices[i],
        snub_dodecahedron_vertices[snub_dodecahedron_adjacent_vertices[i][0]]
    )
    // your vertical module centered at the origin here. For example:
    sphere(r=0.2,$fn=64);

// to arrange modules along the edges
for(i=[0:len(snub_dodecahedron_edges)-1])
    orient_edge(
        snub_dodecahedron_vertices[snub_dodecahedron_edges[i][0]],
        snub_dodecahedron_vertices[snub_dodecahedron_edges[i][1]]
    )
    // your vertical module centered at the origin here. For example:
    cylinder(height=1,r=0.1,center=true,$fn=32);

// to arrange modules on the faces
for(i=[0:len(snub_dodecahedron_faces)-1])
    orient_face(
        map_verts(snub_dodecahedron_vertices, snub_dodecahedron_faces[i])
    )
    // your module on the x-y plane here, centered at the origin. For example:
    rotate(180/len(snub_dodecahedron_faces[i])-90)
    cylinder(r=0.3,h=0.02,$fn=len(snub_dodecahedron_faces[i]));

// to construct a solid
polyhedron(
   points = snub_dodecahedron_vertices,
   faces = snub_dodecahedron_faces
);

*/


/**********************/
/**Geodesic functions**/
/**********************/

/*
- verts is an array of 3-vectors
- face is an aray of indices into verts
- returns an array of the 3-vectors indexed by the face array
*/
function map_verts(verts, face) =
  [ for(i=[0:len(face)-1]) verts[face[i]] ];

/*
- verts is an array of 3-vectors.
- i and sum should use their default values
- returns the sum of all verts as a 3-vector
*/
function sum_verts(verts, i=0, sum=[0,0,0]) =
  i<len(verts) ? sum_verts(verts, i+1, verts[i] + sum) : sum ;

/*
- arrays is an array of arrays containing vertex indices.
- teturns an array that is the concatenation of all child arrays
*/
function concat_all(arrays, i=0, final_array=[]) =
  len(arrays) <= i ? final_array : concat_all(arrays, i+1, concat(arrays[i], final_array));

/*
- a and b are 3-vectors
- transforms a vertical (along z axis) module height of norm(a-b) and centered at the origin such that the ends of the object now lie at positions a and b and such that the x-z plane in the original coordinate system still intersects the origin, with the x+ axis facing away from the origin.
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
- transforms a vertical (along z axis) module from the origin to point a such that the z-axis of the original coordinate system still intersects the origin, and that the x-axis of the original coordinate system lies in the plane formed by a, b and the origin.
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

/*
- verts is an array of the vertices that make up a single face.
- transforms an object centered at the origin to lie at the center of the face with the z+ axis perpendicular to the face and with the x-axis of the original coordinate system parallel with the first edge in the face.
*/
module orient_face(verts) {
    u = verts[0] - verts[1] ;
    uhat = u/norm(u);
    q = verts[1] - verts[2] ;
    w = cross(q,u);
    what = w/norm(w);
    vhat = cross(what,uhat);

    center = sum_verts(verts)/len(verts) ;

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

tetrahedron_vertices=[[1,1,1],[1,-1,-1],[-1,1,-1],[-1,-1,1]]/sqrt(8);
tetrahedron_edges=[[0,1],[1,2],[0,2],[2,3],[1,3],[0,3]];
tetrahedron_adjacent_vertices=[[1,2,3],[0,2,3],[0,1,3],[0,1,2]];
tetrahedron_faces=[[0,2,1],[3,0,1],[1,2,3],[3,2,0]];
hexahedron_vertices=[[-1,-1,-1],[1,-1,-1],[-1,1,-1],[1,1,-1],[-1,-1,1],[1,-1,1],[-1,1,1],[1,1,1]]/2;
hexahedron_edges=[[0,1],[0,2],[1,3],[2,3],[4,5],[4,6],[5,7],[6,7],[0,4],[1,5],[2,6],[3,7]];
hexahedron_faces=[[2,6,4,0],[3,7,6,2],[1,5,7,3],[0,4,5,1],[6,7,5,4],[3,2,0,1],];
hexahedron_adjacent_vertices=[[1,2,4],[0,5,3],[0,6,3],[1,2,7],[0,5,6],[1,7,4],[2,7,4],[5,6,3]];
octahedron_vertices=[[1,0,0],[-1,0,0],[0,1,0],[0,-1,0],[0,0,1],[0,0,-1]]/sqrt(2);
octahedron_edges=[[0,2],[2,1],[1,3],[0,3],[0,4],[1,4],[2,4],[3,4],[0,5],[1,5],[2,5],[3,5]];
octahedron_adjacent_vertices=[[5,2,3,4],[5,2,3,4],[0,1,5,4],[0,1,5,4],[0,1,2,3],[0,1,2,3]];
octahedron_faces=[[2,4,1],[1,4,3],[3,4,0],[0,4,2],[5,0,2],[5,2,1],[5,1,3],[5,3,0]];
dodecahedron_vertices=[[-1,-1,-1],[1,-1,-1],[-1,1,-1],[1,1,-1],[-1,-1,1],[1,-1,1],[-1,1,1],[1,1,1],[0,polyhedraPhi,1/polyhedraPhi],[0,-polyhedraPhi,1/polyhedraPhi],[0,polyhedraPhi,-1/polyhedraPhi],[0,-polyhedraPhi,-1/polyhedraPhi],[1/polyhedraPhi,0,polyhedraPhi],[-1/polyhedraPhi,0,polyhedraPhi],[1/polyhedraPhi,0,-polyhedraPhi],[-1/polyhedraPhi,0,-polyhedraPhi],[polyhedraPhi,1/polyhedraPhi,0],[-polyhedraPhi,1/polyhedraPhi,0],[polyhedraPhi,-1/polyhedraPhi,0],[-polyhedraPhi,-1/polyhedraPhi,0]]/(2/polyhedraPhi);
dodecahedron_edges=[[8,10],[8,6],[8,7],[10,2],[10,3],[9,11],[9,4],[9,5],[11,0],[11,1],[12,13],[12,5],[12,7],[13,4],[13,6],[14,15],[14,1],[14,3],[15,0],[15,2],[16,18],[16,7],[16,3],[18,1],[18,5],[17,19],[17,2],[17,6],[19,0],[19,4]];
dodecahedron_adjacent_vertices=[[15,19,11],[18,14,11],[15,17,10],[16,10,14],[9,19,13],[12,9,18],[13,17,8],[12,16,8],[6,10,7],[5,4,11],[2,3,8],[0,9,1],[13,5,7],[12,6,4],[15,1,3],[0,2,14],[3,18,7],[19,2,6],[1,16,5],[0,17,4]];
dodecahedron_faces=[[16,18,5,12,7],[3,16,7,8,10],[2,10,8,6,17],[17,6,13,4,19],[4,13,12,5,9],[13,6,8,7,12],[10,2,15,14,3],[3,14,1,18,16],[18,1,11,9,5],[9,11,0,19,4],[19,0,15,2,17],[11,1,14,15,0]];
icosahedron_vertices=[[0,1,polyhedraPhi],[0,-1,polyhedraPhi],[0,1,-polyhedraPhi],[0,-1,-polyhedraPhi],[polyhedraPhi,0,1],[polyhedraPhi,0,-1],[-polyhedraPhi,0,1],[-polyhedraPhi,0,-1],[1,polyhedraPhi,0],[-1,polyhedraPhi,0],[1,-polyhedraPhi,0],[-1,-polyhedraPhi,0]]/2;
icosahedron_edges=[[0,1],[0,4],[1,4],[0,6],[1,6],[2,3],[2,5],[3,5],[2,7],[3,7],[4,5],[4,8],[5,8],[4,10],[5,10],[6,7],[6,9],[7,9],[6,11],[7,11],[8,9],[8,0],[9,0],[8,2],[9,2],[10,11],[10,1],[11,1],[10,3],[11,3]];
icosahedron_adjacent_vertices=[[1,6,9,8,4],[0,10,6,11,4],[5,9,7,3,8],[5,10,2,7,11],[0,5,10,1,8],[10,2,3,8,4],[0,1,9,7,11],[6,9,2,3,11],[0,5,9,2,4],[0,6,2,7,8],[5,1,3,11,4],[10,1,6,7,3]];
icosahedron_faces=[[8,4,0],[8,0,9],[9,0,6],[6,0,1],[1,0,4],[11,1,10],[10,1,4],[10,4,5],[5,4,8],[5,8,2],[2,8,9],[2,9,7],[7,9,6],[7,6,11],[11,6,1],[11,3,7],[10,3,11],[5,3,10],[5,2,3],[2,7,3]];
cubeoctahedron_vertices=[[1,1,0],[-1,1,0],[1,-1,0],[-1,-1,0],[1,0,1],[-1,0,1],[1,0,-1],[-1,0,-1],[0,1,1],[0,-1,1],[0,1,-1],[0,-1,-1]]/sqrt(2);
cubeoctahedron_edges=[[0,8],[8,1],[1,10],[10,0],[2,9],[9,3],[3,11],[11,2],[0,4],[4,2],[2,6],[6,0],[3,5],[5,1],[1,7],[7,3],[8,4],[4,9],[9,5],[5,8],[10,6],[6,11],[11,7],[7,10]];
cubeoctahedron_adjacent_vertices=[[6,10,4,8],[5,10,7,8],[9,6,4,11],[9,5,7,11],[0,9,2,8],[9,1,3,8],[0,2,10,11],[1,3,10,11],[0,1,5,4],[5,2,3,4],[0,1,6,7],[2,6,3,7]];
cubeoctahedron_square_faces=[[4,9,5,8],[11,3,9,2],[6,2,4,0],[10,0,8,1],[7,1,5,3],[7,11,6,10]];
cubeoctahedron_triangle_faces=[[7,10,1],[10,6,0],[2,6,11],[11,7,3],[5,1,8],[8,0,4],[4,2,9],[9,3,5]];
cubeoctahedron_faces=concat(cubeoctahedron_square_faces,cubeoctahedron_triangle_faces);
icosidodecahedron_vertices=[[0,0,polyhedraPhi],[0,0,-polyhedraPhi],[0,polyhedraPhi,0],[0,-polyhedraPhi,0],[polyhedraPhi,0,0],[-polyhedraPhi,0,0],[1/2,polyhedraPhi/2,polyhedraPhiSq/2],[-1/2,polyhedraPhi/2,polyhedraPhiSq/2],[1/2,-polyhedraPhi/2,polyhedraPhiSq/2],[-1/2,-polyhedraPhi/2,polyhedraPhiSq/2],[1/2,polyhedraPhi/2,-polyhedraPhiSq/2],[-1/2,polyhedraPhi/2,-polyhedraPhiSq/2],[1/2,-polyhedraPhi/2,-polyhedraPhiSq/2],[-1/2,-polyhedraPhi/2,-polyhedraPhiSq/2],[polyhedraPhi/2,polyhedraPhiSq/2,1/2],[polyhedraPhi/2,polyhedraPhiSq/2,-1/2],[-polyhedraPhi/2,polyhedraPhiSq/2,1/2],[-polyhedraPhi/2,polyhedraPhiSq/2,-1/2],[polyhedraPhi/2,-polyhedraPhiSq/2,1/2],[polyhedraPhi/2,-polyhedraPhiSq/2,-1/2],[-polyhedraPhi/2,-polyhedraPhiSq/2,1/2],[-polyhedraPhi/2,-polyhedraPhiSq/2,-1/2],[polyhedraPhiSq/2,1/2,polyhedraPhi/2],[polyhedraPhiSq/2,-1/2,polyhedraPhi/2],[polyhedraPhiSq/2,1/2,-polyhedraPhi/2],[polyhedraPhiSq/2,-1/2,-polyhedraPhi/2],[-polyhedraPhiSq/2,1/2,polyhedraPhi/2],[-polyhedraPhiSq/2,-1/2,polyhedraPhi/2],[-polyhedraPhiSq/2,1/2,-polyhedraPhi/2],[-polyhedraPhiSq/2,-1/2,-polyhedraPhi/2]]/sqrt((0-1/2)*(0-1/2)+(0-polyhedraPhi/2)*(0-polyhedraPhi/2)+(polyhedraPhi-polyhedraPhiSq/2)*(polyhedraPhi-polyhedraPhiSq/2));
icosidodecahedron_edges=[[4,25],[25,12],[12,13],[13,29],[29,5],[5,26],[26,7],[7,6],[6,22],[22,4],[4,23],[23,8],[8,9],[9,27],[27,5],[5,28],[28,11],[11,10],[10,24],[24,4],[2,14],[14,22],[22,23],[23,18],[18,3],[3,21],[21,29],[29,28],[28,17],[17,2],[2,15],[15,24],[24,25],[25,19],[19,3],[3,20],[20,27],[27,26],[26,16],[16,2],[0,6],[6,14],[14,15],[15,10],[10,1],[1,13],[13,21],[21,20],[20,9],[9,0],[0,8],[8,18],[18,19],[19,12],[12,1],[1,11],[11,17],[17,16],[16,7],[7,0]];
icosidodecahedron_adjacent_vertices=[[9,6,7,8],[12,13,10,11],[15,16,17,14],[19,20,21,18],[24,25,22,23],[27,28,29,26],[0,7,22,14],[0,16,6,26],[0,9,18,23],[0,27,20,8],[15,1,24,11],[1,17,28,10],[19,1,13,25],[12,1,21,29],[15,2,6,22],[2,24,10,14],[2,17,7,26],[16,2,28,11],[19,3,8,23],[12,3,18,25],[27,9,3,21],[13,20,3,29],[6,4,14,23],[18,4,22,8],[15,10,25,4],[12,19,24,4],[27,16,5,7],[9,5,20,26],[5,17,11,29],[13,5,21,28]];
icosidodecahedron_triangle_faces=[[6,0,7],[22,6,14],[16,7,26],[5,26,27],[28,5,29],[13,29,21],[1,13,12],[12,19,25],[25,4,24],[4,23,22],[0,8,9],[9,20,27],[20,3,21],[3,18,19],[18,8,23],[15,14,2],[2,16,17],[11,17,28],[10,11,1],[24,15,10]];
icosidodecahedron_pentagon_faces=[[17,16,26,5,28],[14,6,7,16,2],[26,7,0,9,27],[20,9,8,18,3],[0,6,22,23,8],[27,20,21,29,5],[21,3,19,12,13],[19,18,23,4,25],[4,22,14,15,24],[10,15,2,17,11],[1,11,28,29,13],[10,1,12,25,24]];
icosidodecahedron_faces=concat(icosidodecahedron_triangle_faces,icosidodecahedron_pentagon_faces);
truncated_tetrahedron_vertices=[[+3,+1,+1],[+1,+3,+1],[+1,+1,+3],[-3,-1,+1],[-1,-3,+1],[-1,-1,+3],[-3,+1,-1],[-1,+3,-1],[-1,+1,-3],[+3,-1,-1],[+1,-3,-1],[+1,-1,-3]]/sqrt(8);
truncated_tetrahedron_edges=[[0,1],[0,2],[1,2],[3,4],[3,5],[4,5],[9,10],[9,11],[10,11],[6,7],[6,8],[7,8],[2,5],[4,10],[0,9],[11,8],[6,3],[7,1]];
truncated_tetrahedron_adjacent_vertices=[[9,1,2],[0,2,7],[0,1,5],[5,6,4],[5,3,10],[2,3,4],[3,7,8],[1,6,8],[6,7,11],[0,10,11],[9,4,11],[9,10,8]];
truncated_tetrahedron_triangle_faces=[[0,2,1],[3,5,4],[10,9,11],[7,6,8]];
truncated_tetrahedron_hexagon_faces=[[8,6,3,4,10,11],[1,2,5,3,6,7],[9,0,1,7,8,11],[10,4,5,2,0,9]];
truncated_tetrahedron_faces=concat(truncated_tetrahedron_triangle_faces,truncated_tetrahedron_hexagon_faces);
truncated_hexahedron_vertices=[[polyhedraZeta,1,1],[polyhedraZeta,1,-1],[polyhedraZeta,-1,1],[polyhedraZeta,-1,-1],[-polyhedraZeta,1,1],[-polyhedraZeta,1,-1],[-polyhedraZeta,-1,1],[-polyhedraZeta,-1,-1],[1,polyhedraZeta,1],[1,polyhedraZeta,-1],[1,-polyhedraZeta,1],[1,-polyhedraZeta,-1],[-1,polyhedraZeta,1],[-1,polyhedraZeta,-1],[-1,-polyhedraZeta,1],[-1,-polyhedraZeta,-1],[1,1,polyhedraZeta],[1,1,-polyhedraZeta],[1,-1,polyhedraZeta],[1,-1,-polyhedraZeta],[-1,1,polyhedraZeta],[-1,1,-polyhedraZeta],[-1,-1,polyhedraZeta],[-1,-1,-polyhedraZeta]];
truncated_hexahedron_edges=[[2,10],[2,18],[10,18],[0,8],[0,16],[8,16],[4,20],[4,12],[12,20],[6,14],[6,22],[14,22],[3,11],[3,19],[11,19],[7,15],[7,23],[15,23],[5,13],[5,21],[13,21],[1,17],[1,9],[9,17],[17,16],[8,10],[18,19],[9,11],[14,12],[20,21],[13,15],[22,23],[6,2],[7,3],[1,5],[0,4]];
truncated_hexahedron_adjacent_vertices=[[16,4,8],[9,5,17],[6,18,10],[19,7,11],[0,12,20],[1,13,21],[2,22,14],[15,3,23],[0,16,10],[1,17,11],[2,18,8],[9,19,3],[20,4,14],[15,5,21],[12,6,22],[13,7,23],[0,17,8],[9,1,16],[19,2,10],[3,18,11],[12,21,4],[13,5,20],[6,14,23],[15,7,22]];
truncated_hexahedron_triangle_faces=[[16,8,0],[20,4,12],[22,14,6],[2,10,18],[19,11,3],[9,17,1],[5,21,13],[15,23,7]];
truncated_hexahedron_octagon_faces=[[23,22,6,2,18,19,3,7],[19,18,10,8,16,17,9,11],[17,16,0,4,20,21,5,1],[21,20,12,14,22,23,15,13],[0,8,10,2,6,14,12,4],[13,15,7,3,11,9,1,5]];
truncated_hexahedron_faces=concat(truncated_hexahedron_triangle_faces,truncated_hexahedron_octagon_faces);
truncated_octahedron_vertices=[[2,1,0],[2,-1,0],[2,0,1],[2,0,-1],[-2,1,0],[-2,-1,0],[-2,0,1],[-2,0,-1],[1,2,0],[-1,2,0],[0,2,1],[0,2,-1],[1,-2,0],[-1,-2,0],[0,-2,1],[0,-2,-1],[1,0,2],[-1,0,2],[0,1,2],[0,-1,2],[1,0,-2],[-1,0,-2],[0,1,-2],[0,-1,-2]]/sqrt(2);
truncated_octahedron_edges=[[0,2],[2,1],[1,3],[3,0],[5,6],[6,4],[4,7],[7,5],[9,10],[10,8],[8,11],[11,9],[13,14],[14,12],[12,15],[15,13],[17,18],[18,16],[16,19],[19,17],[21,22],[22,20],[20,23],[23,21],[2,16],[19,14],[17,6],[18,10],[15,23],[20,3],[22,11],[21,7],[5,13],[4,9],[8,0],[1,12]];
truncated_octahedron_adjacent_vertices=[[2,3,8],[12,2,3],[0,1,16],[0,1,20],[9,6,7],[13,6,7],[5,17,4],[5,21,4],[0,10,11],[10,4,11],[9,18,8],[9,22,8],[15,1,14],[15,5,14],[12,19,13],[12,13,23],[19,2,18],[19,6,18],[16,17,10],[16,17,14],[3,22,23],[7,22,23],[20,21,11],[15,20,21]];
truncated_octahedron_square_faces=[[18,16,19,17],[4,6,5,7],[13,14,12,15],[1,2,0,3],[8,10,9,11],[20,22,21,23]];
truncated_octahedron_hexagon_faces=[[11,22,20,3,0,8],[3,20,23,15,12,1],[15,23,21,7,5,13],[7,21,22,11,9,4],[2,1,12,14,19,16],[14,13,5,6,17,19],[6,4,9,10,18,17],[10,8,0,2,16,18]];
truncated_octahedron_faces=concat(truncated_octahedron_square_faces,truncated_octahedron_hexagon_faces);
rhombicuboctahedron_vertices=[[1,1,polyhedraR2P1],[1,1,-polyhedraR2P1],[1,-1,polyhedraR2P1],[1,-1,-polyhedraR2P1],[-1,1,polyhedraR2P1],[-1,1,-polyhedraR2P1],[-1,-1,polyhedraR2P1],[-1,-1,-polyhedraR2P1],[1,polyhedraR2P1,1],[1,polyhedraR2P1,-1],[1,-polyhedraR2P1,1],[1,-polyhedraR2P1,-1],[-1,polyhedraR2P1,1],[-1,polyhedraR2P1,-1],[-1,-polyhedraR2P1,1],[-1,-polyhedraR2P1,-1],[polyhedraR2P1,1,1],[polyhedraR2P1,1,-1],[polyhedraR2P1,-1,1],[polyhedraR2P1,-1,-1],[-polyhedraR2P1,1,1],[-polyhedraR2P1,1,-1],[-polyhedraR2P1,-1,1],[-polyhedraR2P1,-1,-1],]/2;
rhombicuboctahedron_edges=[[3,19],[19,11],[11,3],[1,9],[9,17],[17,1],[5,13],[13,21],[21,5],[7,15],[15,23],[23,7],[2,10],[10,18],[18,2],[0,8],[8,16],[16,0],[4,12],[12,20],[20,4],[6,14],[14,22],[22,6],[6,4],[4,0],[0,2],[2,6],[10,11],[11,15],[15,14],[14,10],[17,19],[19,18],[18,16],[16,17],[8,9],[9,13],[13,12],[12,8],[20,21],[21,23],[23,22],[22,20],[1,3],[3,7],[7,5],[5,1]];
rhombicuboctahedron_adjacent_vertices=[[16,2,4,8],[9,5,17,3],[0,6,18,10],[19,1,7,11],[0,12,20,6],[1,13,21,7],[2,22,4,14],[15,5,3,23],[0,12,9,16],[1,13,17,8],[2,18,14,11],[15,19,3,10],[13,20,4,8],[12,9,5,21],[15,6,10,22],[7,14,11,23],[0,17,18,8],[9,1,19,16],[19,16,2,10],[17,3,18,11],[12,21,4,22],[13,5,20,23],[20,6,14,23],[15,21,7,22]];
rhombicuboctahedron_triangle_faces=[[10,2,18],[16,0,8],[12,4,20],[22,6,14],[3,11,19],[1,17,9],[5,13,21],[7,23,15]];
rhombicuboctahedron_square_faces=[[0,2,6,4],[20,4,6,22],[14,6,2,10],[18,2,0,16],[8,0,4,12],[17,16,8,9],[9,8,12,13],[13,12,20,21],[21,20,22,23],[23,22,14,15],[15,14,10,11],[11,10,18,19],[19,18,16,17],[1,3,19,17],[1,9,13,5],[5,21,23,7],[7,15,11,3],[7,3,1,5]];
rhombicuboctahedron_faces=concat(rhombicuboctahedron_triangle_faces,rhombicuboctahedron_square_faces);
truncated_cuboctahedron_vertices=[[1,polyhedraR2P1,polyhedra2R2P1],[1,polyhedraR2P1,-polyhedra2R2P1],[1,-polyhedraR2P1,polyhedra2R2P1],[1,-polyhedraR2P1,-polyhedra2R2P1],[-1,polyhedraR2P1,polyhedra2R2P1],[-1,polyhedraR2P1,-polyhedra2R2P1],[-1,-polyhedraR2P1,polyhedra2R2P1],[-1,-polyhedraR2P1,-polyhedra2R2P1],[polyhedra2R2P1,1,polyhedraR2P1],[polyhedra2R2P1,1,-polyhedraR2P1],[polyhedra2R2P1,-1,polyhedraR2P1],[polyhedra2R2P1,-1,-polyhedraR2P1],[-polyhedra2R2P1,1,polyhedraR2P1],[-polyhedra2R2P1,1,-polyhedraR2P1],[-polyhedra2R2P1,-1,polyhedraR2P1],[-polyhedra2R2P1,-1,-polyhedraR2P1],[polyhedraR2P1,polyhedra2R2P1,1],[polyhedraR2P1,polyhedra2R2P1,-1],[polyhedraR2P1,-polyhedra2R2P1,1],[polyhedraR2P1,-polyhedra2R2P1,-1],[-polyhedraR2P1,polyhedra2R2P1,1],[-polyhedraR2P1,polyhedra2R2P1,-1],[-polyhedraR2P1,-polyhedra2R2P1,1],[-polyhedraR2P1,-polyhedra2R2P1,-1],[polyhedraR2P1,1,polyhedra2R2P1],[polyhedraR2P1,1,-polyhedra2R2P1],[polyhedraR2P1,-1,polyhedra2R2P1],[polyhedraR2P1,-1,-polyhedra2R2P1],[-polyhedraR2P1,1,polyhedra2R2P1],[-polyhedraR2P1,1,-polyhedra2R2P1],[-polyhedraR2P1,-1,polyhedra2R2P1],[-polyhedraR2P1,-1,-polyhedra2R2P1],[polyhedra2R2P1,polyhedraR2P1,1],[polyhedra2R2P1,polyhedraR2P1,-1],[polyhedra2R2P1,-polyhedraR2P1,1],[polyhedra2R2P1,-polyhedraR2P1,-1],[-polyhedra2R2P1,polyhedraR2P1,1],[-polyhedra2R2P1,polyhedraR2P1,-1],[-polyhedra2R2P1,-polyhedraR2P1,1],[-polyhedra2R2P1,-polyhedraR2P1,-1],[1,polyhedra2R2P1,polyhedraR2P1],[1,polyhedra2R2P1,-polyhedraR2P1],[1,-polyhedra2R2P1,polyhedraR2P1],[1,-polyhedra2R2P1,-polyhedraR2P1],[-1,polyhedra2R2P1,polyhedraR2P1],[-1,polyhedra2R2P1,-polyhedraR2P1],[-1,-polyhedra2R2P1,polyhedraR2P1],[-1,-polyhedra2R2P1,-polyhedraR2P1]]/2;
truncated_cuboctahedron_edges=[[20,21],[21,45],[45,41],[41,17],[17,16],[16,40],[40,44],[44,20],[8,32],[32,33],[33,9],[9,11],[11,35],[35,34],[34,10],[10,8],[22,23],[23,47],[47,43],[43,19],[19,18],[18,42],[42,46],[46,22],[36,37],[37,13],[13,15],[15,39],[39,38],[38,14],[14,12],[12,36],[0,4],[4,28],[28,30],[30,6],[6,2],[2,26],[26,24],[24,0],[5,1],[1,25],[25,27],[27,3],[3,7],[7,31],[31,29],[29,5],[4,44],[20,36],[12,28],[14,30],[6,46],[22,38],[2,42],[26,10],[18,34],[0,40],[16,32],[8,24],[37,21],[45,5],[29,13],[27,11],[35,19],[3,43],[39,23],[7,47],[15,31],[1,41],[17,33],[25,9]];
truncated_cuboctahedron_adjacent_vertices=[[24,4,40],[5,25,41],[6,42,26],[27,7,43],[0,28,44],[45,1,29],[30,46,2],[31,3,47],[32,24,10],[33,25,11],[34,8,26],[9,27,35],[36,28,14],[15,37,29],[12,30,38],[13,31,39],[17,32,40],[33,16,41],[19,34,42],[35,18,43],[21,36,44],[45,37,20],[46,38,23],[39,22,47],[0,26,8],[27,9,1],[2,24,10],[3,25,11],[30,12,4],[31,13,5],[6,28,14],[15,7,29],[33,16,8],[9,17,32],[35,18,10],[19,34,11],[12,37,20],[13,21,36],[39,22,14],[15,38,23],[0,16,44],[45,1,17],[46,2,18],[19,3,47],[20,40,4],[5,21,41],[42,6,22],[43,7,23]];
truncated_cuboctahedron_square_faces=[[40,0,4,44],[12,28,30,14],[46,6,2,42],[10,26,24,8],[32,16,17,33],[20,36,37,21],[39,38,22,23],[18,34,35,19],[11,9,25,27],[1,41,45,5],[29,13,15,31],[7,47,43,3]];
truncated_cuboctahedron_hexagon_faces=[[38,14,30,6,46,22],[42,2,26,10,34,18],[32,8,24,0,40,16],[44,4,28,12,36,20],[31,15,39,23,47,7],[3,43,19,35,11,27],[9,33,17,41,1,25],[5,45,21,37,13,29]];
truncated_cuboctahedron_octagon_faces=[[4,0,24,26,2,6,30,28],[37,36,12,14,38,39,15,13],[42,18,19,43,47,23,22,46],[11,35,34,10,8,32,33,9],[21,45,41,17,16,40,44,20],[29,31,7,3,27,25,1,5]];
truncated_cuboctahedron_faces=concat(truncated_cuboctahedron_square_faces,truncated_cuboctahedron_hexagon_faces,truncated_cuboctahedron_octagon_faces);
snub_cube_vertices=[[1,1/polyhedraTribConst,polyhedraTribConst],[1,-1/polyhedraTribConst,-polyhedraTribConst],[-1,1/polyhedraTribConst,-polyhedraTribConst],[-1,-1/polyhedraTribConst,polyhedraTribConst],[polyhedraTribConst,1,1/polyhedraTribConst],[polyhedraTribConst,-1,-1/polyhedraTribConst],[-polyhedraTribConst,1,-1/polyhedraTribConst],[-polyhedraTribConst,-1,1/polyhedraTribConst],[1/polyhedraTribConst,polyhedraTribConst,1],[1/polyhedraTribConst,-polyhedraTribConst,-1],[-1/polyhedraTribConst,polyhedraTribConst,-1],[-1/polyhedraTribConst,-polyhedraTribConst,1],[1/polyhedraTribConst,1,-polyhedraTribConst],[-1/polyhedraTribConst,1,polyhedraTribConst],[1/polyhedraTribConst,-1,polyhedraTribConst],[-1/polyhedraTribConst,-1,-polyhedraTribConst],[1,polyhedraTribConst,-1/polyhedraTribConst],[-1,polyhedraTribConst,1/polyhedraTribConst],[1,-polyhedraTribConst,1/polyhedraTribConst],[-1,-polyhedraTribConst,-1/polyhedraTribConst],[polyhedraTribConst,1/polyhedraTribConst,-1],[-polyhedraTribConst,1/polyhedraTribConst,1],[polyhedraTribConst,-1/polyhedraTribConst,1],[-polyhedraTribConst,-1/polyhedraTribConst,-1]]/polyhedraSnubCubeAlpha;
snub_cube_edges=[[13,0],[0,14],[14,3],[3,13],[4,20],[20,5],[5,22],[22,4],[8,16],[16,10],[10,17],[17,8],[7,23],[23,6],[6,21],[21,7],[9,18],[18,11],[11,19],[19,9],[1,12],[12,2],[2,15],[15,1],[14,22],[22,0],[0,4],[4,8],[8,0],[8,13],[13,17],[17,21],[21,13],[21,3],[3,7],[7,11],[11,3],[11,14],[14,18],[18,22],[1,9],[9,15],[15,19],[19,23],[23,15],[23,2],[2,6],[6,10],[10,2],[10,12],[12,16],[16,20],[20,12],[20,1],[1,5],[9,5],[5,18],[16,4],[6,17],[19,7]];
snub_cube_adjacent_vertices=[[14,13,22,8,4],[5,20,9,12,15],[10,6,12,23,15],[14,21,13,7,11],[0,20,22,16,8],[20,1,9,22,18],[10,21,2,17,23],[21,3,11,23,19],[0,13,17,16,4],[5,1,18,19,15],[6,2,17,12,16],[14,7,3,18,19],[10,20,1,2,16],[0,21,17,3,8],[0,22,3,18,11],[1,9,2,23,19],[10,20,12,8,4],[10,6,21,13,8],[5,14,9,22,11],[9,7,11,23,15],[5,1,12,16,4],[6,13,17,7,3],[0,5,14,18,4],[6,2,7,19,15]];
snub_cube_triangle_faces=[[22,14,0],[22,0,4],[4,0,8],[8,0,13],[17,8,13],[17,13,21],[21,13,3],[7,21,3],[7,3,11],[11,3,14],[18,11,14],[18,14,22],[5,18,22],[20,4,16],[16,4,8],[10,17,6],[6,17,21],[23,7,19],[19,7,11],[9,18,5],[20,16,12],[12,16,10],[2,10,6],[2,6,23],[12,10,2],[2,23,15],[15,23,19],[15,19,9],[15,9,1],[1,9,5],[1,5,20],[1,20,12]];
snub_cube_square_faces=[[0,14,3,13],[16,8,17,10],[6,21,7,23],[19,11,18,9],[5,22,4,20],[1,12,2,15]];
snub_cube_faces=concat(snub_cube_triangle_faces,snub_cube_square_faces);
truncated_dodecahedron_vertices=[[0,1/polyhedraPhi,(2+polyhedraPhi)],[0,1/polyhedraPhi,-(2+polyhedraPhi)],[0,-1/polyhedraPhi,(2+polyhedraPhi)],[0,-1/polyhedraPhi,-(2+polyhedraPhi)],[(2+polyhedraPhi),0,1/polyhedraPhi],[(2+polyhedraPhi),0,-1/polyhedraPhi],[-(2+polyhedraPhi),0,1/polyhedraPhi],[-(2+polyhedraPhi),0,-1/polyhedraPhi],[1/polyhedraPhi,(2+polyhedraPhi),0],[1/polyhedraPhi,-(2+polyhedraPhi),0],[-1/polyhedraPhi,(2+polyhedraPhi),0],[-1/polyhedraPhi,-(2+polyhedraPhi),0],[1/polyhedraPhi,polyhedraPhi,2*polyhedraPhi],[1/polyhedraPhi,polyhedraPhi,-2*polyhedraPhi],[1/polyhedraPhi,-polyhedraPhi,2*polyhedraPhi],[1/polyhedraPhi,-polyhedraPhi,-2*polyhedraPhi],[-1/polyhedraPhi,polyhedraPhi,2*polyhedraPhi],[-1/polyhedraPhi,polyhedraPhi,-2*polyhedraPhi],[-1/polyhedraPhi,-polyhedraPhi,2*polyhedraPhi],[-1/polyhedraPhi,-polyhedraPhi,-2*polyhedraPhi],[2*polyhedraPhi,1/polyhedraPhi,polyhedraPhi],[2*polyhedraPhi,1/polyhedraPhi,-polyhedraPhi],[2*polyhedraPhi,-1/polyhedraPhi,polyhedraPhi],[2*polyhedraPhi,-1/polyhedraPhi,-polyhedraPhi],[-2*polyhedraPhi,1/polyhedraPhi,polyhedraPhi],[-2*polyhedraPhi,1/polyhedraPhi,-polyhedraPhi],[-2*polyhedraPhi,-1/polyhedraPhi,polyhedraPhi],[-2*polyhedraPhi,-1/polyhedraPhi,-polyhedraPhi],[polyhedraPhi,2*polyhedraPhi,1/polyhedraPhi],[polyhedraPhi,2*polyhedraPhi,-1/polyhedraPhi],[polyhedraPhi,-2*polyhedraPhi,1/polyhedraPhi],[polyhedraPhi,-2*polyhedraPhi,-1/polyhedraPhi],[-polyhedraPhi,2*polyhedraPhi,1/polyhedraPhi],[-polyhedraPhi,2*polyhedraPhi,-1/polyhedraPhi],[-polyhedraPhi,-2*polyhedraPhi,1/polyhedraPhi],[-polyhedraPhi,-2*polyhedraPhi,-1/polyhedraPhi],[polyhedraPhi,2,(1+polyhedraPhi)],[polyhedraPhi,2,-(1+polyhedraPhi)],[polyhedraPhi,-2,(1+polyhedraPhi)],[polyhedraPhi,-2,-(1+polyhedraPhi)],[-polyhedraPhi,2,(1+polyhedraPhi)],[-polyhedraPhi,2,-(1+polyhedraPhi)],[-polyhedraPhi,-2,(1+polyhedraPhi)],[-polyhedraPhi,-2,-(1+polyhedraPhi)],[(1+polyhedraPhi),polyhedraPhi,2],[(1+polyhedraPhi),polyhedraPhi,-2],[(1+polyhedraPhi),-polyhedraPhi,2],[(1+polyhedraPhi),-polyhedraPhi,-2],[-(1+polyhedraPhi),polyhedraPhi,2],[-(1+polyhedraPhi),polyhedraPhi,-2],[-(1+polyhedraPhi),-polyhedraPhi,2],[-(1+polyhedraPhi),-polyhedraPhi,-2],[2,(1+polyhedraPhi),polyhedraPhi],[2,(1+polyhedraPhi),-polyhedraPhi],[2,-(1+polyhedraPhi),polyhedraPhi],[2,-(1+polyhedraPhi),-polyhedraPhi],[-2,(1+polyhedraPhi),polyhedraPhi],[-2,(1+polyhedraPhi),-polyhedraPhi],[-2,-(1+polyhedraPhi),polyhedraPhi],[-2,-(1+polyhedraPhi),-polyhedraPhi]]/(2*polyhedraPhi-2);
truncated_dodecahedron_edges=[[0,2],[2,14],[14,38],[38,46],[46,22],[22,20],[20,44],[44,36],[36,12],[12,0],[49,41],[41,17],[17,1],[1,3],[3,19],[19,43],[43,51],[51,27],[27,25],[25,49],[22,4],[4,5],[5,23],[23,47],[47,55],[55,31],[31,30],[30,54],[54,46],[44,52],[52,28],[28,29],[29,53],[53,45],[45,21],[21,5],[4,20],[36,52],[28,8],[8,10],[10,32],[32,56],[56,40],[40,16],[16,12],[0,16],[40,48],[48,24],[24,26],[26,50],[50,42],[42,18],[18,2],[18,14],[38,54],[30,9],[9,11],[11,34],[34,58],[58,42],[58,50],[26,6],[6,7],[7,27],[51,59],[59,35],[35,34],[59,43],[19,15],[15,39],[39,55],[31,9],[35,11],[15,3],[1,13],[13,37],[37,45],[21,23],[47,39],[37,53],[29,8],[10,33],[33,57],[57,41],[17,13],[48,56],[32,33],[57,49],[25,7],[6,24]];
truncated_dodecahedron_adjacent_vertices=[[12,16,2],[13,17,3],[0,18,14],[15,1,19],[5,20,22],[21,4,23],[24,7,26],[27,6,25],[28,10,29],[30,31,11],[33,32,8],[9,34,35],[0,16,36],[1,37,17],[2,38,18],[19,39,3],[0,12,40],[1,13,41],[2,42,14],[15,3,43],[22,4,44],[45,5,23],[46,20,4],[5,21,47],[48,6,26],[27,49,7],[50,24,6],[51,25,7],[52,29,8],[53,28,8],[9,31,54],[30,9,55],[33,56,10],[32,57,10],[35,58,11],[34,11,59],[12,52,44],[45,13,53],[46,54,14],[15,55,47],[48,16,56],[49,17,57],[50,18,58],[51,19,59],[52,20,36],[37,53,21],[38,54,22],[39,55,23],[56,24,40],[57,25,41],[42,58,26],[27,43,59],[36,28,44],[45,37,29],[30,46,38],[31,39,47],[48,32,40],[33,49,41],[34,50,42],[51,35,43]];
truncated_dodecahedron_triangle_faces=[[0,16,12],[14,18,2],[40,48,56],[24,26,6],[50,42,58],[54,38,46],[22,20,4],[44,36,52],[29,28,8],[10,32,33],[25,7,27],[35,34,11],[9,30,31],[39,55,47],[23,5,21],[45,53,37],[1,13,17],[41,57,49],[51,59,43],[3,19,15]];
truncated_dodecahedron_decagon_faces=[[2,0,12,36,44,20,22,46,38,14],[12,16,40,56,32,10,8,28,52,36],[0,2,18,42,50,26,24,48,40,16],[34,58,42,18,14,38,54,30,9,11],[54,46,22,4,5,23,47,55,31,30],[4,20,44,52,28,29,53,45,21,5],[49,25,27,51,43,19,3,1,17,41],[53,29,8,10,33,57,41,17,13,37],[33,32,56,48,24,6,7,25,49,57],[6,26,50,58,34,35,59,51,27,7],[59,35,11,9,31,55,39,15,19,43],[39,47,23,21,45,37,13,1,3,15]];
truncated_dodecahedron_faces=concat(truncated_dodecahedron_triangle_faces,truncated_dodecahedron_decagon_faces);
truncated_icosahedron_vertices=[[0,1,3*polyhedraPhi],[0,1,-3*polyhedraPhi],[0,-1,3*polyhedraPhi],[0,-1,-3*polyhedraPhi],[3*polyhedraPhi,0,1],[3*polyhedraPhi,0,-1],[-3*polyhedraPhi,0,1],[-3*polyhedraPhi,0,-1],[1,3*polyhedraPhi,0],[1,-3*polyhedraPhi,0],[-1,3*polyhedraPhi,0],[-1,-3*polyhedraPhi,0],[1,(2+polyhedraPhi),2*polyhedraPhi],[1,(2+polyhedraPhi),-2*polyhedraPhi],[1,-(2+polyhedraPhi),2*polyhedraPhi],[1,-(2+polyhedraPhi),-2*polyhedraPhi],[-1,(2+polyhedraPhi),2*polyhedraPhi],[-1,(2+polyhedraPhi),-2*polyhedraPhi],[-1,-(2+polyhedraPhi),2*polyhedraPhi],[-1,-(2+polyhedraPhi),-2*polyhedraPhi],[2*polyhedraPhi,1,(2+polyhedraPhi)],[2*polyhedraPhi,1,-(2+polyhedraPhi)],[2*polyhedraPhi,-1,(2+polyhedraPhi)],[2*polyhedraPhi,-1,-(2+polyhedraPhi)],[-2*polyhedraPhi,1,(2+polyhedraPhi)],[-2*polyhedraPhi,1,-(2+polyhedraPhi)],[-2*polyhedraPhi,-1,(2+polyhedraPhi)],[-2*polyhedraPhi,-1,-(2+polyhedraPhi)],[(2+polyhedraPhi),2*polyhedraPhi,1],[(2+polyhedraPhi),2*polyhedraPhi,-1],[(2+polyhedraPhi),-2*polyhedraPhi,1],[(2+polyhedraPhi),-2*polyhedraPhi,-1],[-(2+polyhedraPhi),2*polyhedraPhi,1],[-(2+polyhedraPhi),2*polyhedraPhi,-1],[-(2+polyhedraPhi),-2*polyhedraPhi,1],[-(2+polyhedraPhi),-2*polyhedraPhi,-1],[polyhedraPhi,2,pow(polyhedraPhi,3)],[polyhedraPhi,2,-pow(polyhedraPhi,3)],[polyhedraPhi,-2,pow(polyhedraPhi,3)],[polyhedraPhi,-2,-pow(polyhedraPhi,3)],[-polyhedraPhi,2,pow(polyhedraPhi,3)],[-polyhedraPhi,2,-pow(polyhedraPhi,3)],[-polyhedraPhi,-2,pow(polyhedraPhi,3)],[-polyhedraPhi,-2,-pow(polyhedraPhi,3)],[pow(polyhedraPhi,3),polyhedraPhi,2],[pow(polyhedraPhi,3),polyhedraPhi,-2],[pow(polyhedraPhi,3),-polyhedraPhi,2],[pow(polyhedraPhi,3),-polyhedraPhi,-2],[-pow(polyhedraPhi,3),polyhedraPhi,2],[-pow(polyhedraPhi,3),polyhedraPhi,-2],[-pow(polyhedraPhi,3),-polyhedraPhi,2],[-pow(polyhedraPhi,3),-polyhedraPhi,-2],[2,pow(polyhedraPhi,3),polyhedraPhi],[2,pow(polyhedraPhi,3),-polyhedraPhi],[2,-pow(polyhedraPhi,3),polyhedraPhi],[2,-pow(polyhedraPhi,3),-polyhedraPhi],[-2,pow(polyhedraPhi,3),polyhedraPhi],[-2,pow(polyhedraPhi,3),-polyhedraPhi],[-2,-pow(polyhedraPhi,3),polyhedraPhi],[-2,-pow(polyhedraPhi,3),-polyhedraPhi]]/2;
truncated_icosahedron_edges=[[2,0],[0,36],[36,20],[20,22],[22,38],[38,2],[0,40],[40,24],[24,26],[26,42],[42,2],[22,46],[46,30],[30,54],[54,14],[14,38],[36,12],[12,52],[52,28],[28,44],[44,20],[40,16],[16,56],[56,32],[32,48],[48,24],[26,50],[50,34],[34,58],[58,18],[18,42],[18,14],[58,11],[11,9],[9,54],[30,31],[31,47],[47,5],[5,4],[4,46],[44,4],[28,29],[29,45],[45,5],[16,12],[52,8],[8,10],[10,56],[6,50],[34,35],[35,51],[51,7],[7,6],[6,48],[32,33],[33,49],[49,7],[9,55],[55,15],[15,19],[19,59],[59,11],[15,39],[39,23],[23,47],[31,55],[35,59],[19,43],[43,27],[27,51],[29,53],[53,13],[13,37],[37,21],[21,45],[8,53],[17,13],[10,57],[57,17],[33,57],[41,17],[25,41],[49,25],[27,25],[41,1],[1,3],[3,43],[1,37],[21,23],[3,39]];
truncated_icosahedron_adjacent_vertices=[[2,36,40],[37,3,41],[0,38,42],[1,39,43],[46,5,44],[45,4,47],[48,50,7],[51,49,6],[52,53,10],[54,55,11],[56,57,8],[9,58,59],[52,16,36],[37,53,17],[38,54,18],[19,39,55],[12,56,40],[13,57,41],[42,58,14],[15,43,59],[36,22,44],[45,37,23],[46,20,38],[39,21,47],[48,40,26],[27,49,41],[50,24,42],[51,43,25],[52,29,44],[45,53,28],[31,46,54],[30,55,47],[33,48,56],[49,32,57],[35,50,58],[51,34,59],[0,12,20],[1,13,21],[2,22,14],[15,3,23],[0,16,24],[1,17,25],[2,18,26],[27,19,3],[20,28,4],[5,21,29],[30,22,4],[31,5,23],[32,24,6],[33,7,25],[34,6,26],[27,35,7],[12,28,8],[13,29,8],[30,9,14],[15,9,31],[16,32,10],[33,17,10],[34,18,11],[19,35,11]];
truncated_icosahedron_pentagon_faces=[[46,22,20,44,4],[18,42,2,38,14],[48,24,26,50,6],[36,0,40,16,12],[35,34,58,11,59],[9,54,30,31,55],[28,52,8,53,29],[10,56,32,33,57],[49,7,51,27,25],[43,19,15,39,3],[47,5,45,21,23],[37,13,17,41,1]];
truncated_icosahedron_hexagon_faces=[[16,40,24,48,32,56],[40,0,2,42,26,24],[0,36,20,22,38,2],[44,20,36,12,52,28],[52,12,16,56,10,8],[53,8,10,57,17,13],[17,57,33,49,25,41],[33,32,48,6,7,49],[6,50,34,35,51,7],[50,26,42,18,58,34],[58,18,14,54,9,11],[54,14,38,22,46,30],[31,30,46,4,5,47],[5,4,44,28,29,45],[21,45,29,53,13,37],[39,23,21,37,1,3],[43,3,1,41,25,27],[59,19,43,27,51,35],[55,15,19,59,11,9],[47,23,39,15,55,31]];
truncated_icosahedron_faces=concat(truncated_icosahedron_pentagon_faces,truncated_icosahedron_hexagon_faces);
rhombicosidodecahedron_vertices=[[1,1,pow(polyhedraPhi,3)],[1,1,-pow(polyhedraPhi,3)],[1,-1,pow(polyhedraPhi,3)],[1,-1,-pow(polyhedraPhi,3)],[-1,1,pow(polyhedraPhi,3)],[-1,1,-pow(polyhedraPhi,3)],[-1,-1,pow(polyhedraPhi,3)],[-1,-1,-pow(polyhedraPhi,3)],[pow(polyhedraPhi,3),1,1],[pow(polyhedraPhi,3),1,-1],[pow(polyhedraPhi,3),-1,1],[pow(polyhedraPhi,3),-1,-1],[-pow(polyhedraPhi,3),1,1],[-pow(polyhedraPhi,3),1,-1],[-pow(polyhedraPhi,3),-1,1],[-pow(polyhedraPhi,3),-1,-1],[1,pow(polyhedraPhi,3),1],[1,pow(polyhedraPhi,3),-1],[1,-pow(polyhedraPhi,3),1],[1,-pow(polyhedraPhi,3),-1],[-1,pow(polyhedraPhi,3),1],[-1,pow(polyhedraPhi,3),-1],[-1,-pow(polyhedraPhi,3),1],[-1,-pow(polyhedraPhi,3),-1],[pow(polyhedraPhi,2),polyhedraPhi,2*polyhedraPhi],[pow(polyhedraPhi,2),polyhedraPhi,-2*polyhedraPhi],[pow(polyhedraPhi,2),-polyhedraPhi,2*polyhedraPhi],[pow(polyhedraPhi,2),-polyhedraPhi,-2*polyhedraPhi],[-pow(polyhedraPhi,2),polyhedraPhi,2*polyhedraPhi],[-pow(polyhedraPhi,2),polyhedraPhi,-2*polyhedraPhi],[-pow(polyhedraPhi,2),-polyhedraPhi,2*polyhedraPhi],[-pow(polyhedraPhi,2),-polyhedraPhi,-2*polyhedraPhi],[2*polyhedraPhi,pow(polyhedraPhi,2),polyhedraPhi],[2*polyhedraPhi,pow(polyhedraPhi,2),-polyhedraPhi],[2*polyhedraPhi,-pow(polyhedraPhi,2),polyhedraPhi],[2*polyhedraPhi,-pow(polyhedraPhi,2),-polyhedraPhi],[-2*polyhedraPhi,pow(polyhedraPhi,2),polyhedraPhi],[-2*polyhedraPhi,pow(polyhedraPhi,2),-polyhedraPhi],[-2*polyhedraPhi,-pow(polyhedraPhi,2),polyhedraPhi],[-2*polyhedraPhi,-pow(polyhedraPhi,2),-polyhedraPhi],[polyhedraPhi,2*polyhedraPhi,pow(polyhedraPhi,2)],[polyhedraPhi,2*polyhedraPhi,-pow(polyhedraPhi,2)],[polyhedraPhi,-2*polyhedraPhi,pow(polyhedraPhi,2)],[polyhedraPhi,-2*polyhedraPhi,-pow(polyhedraPhi,2)],[-polyhedraPhi,2*polyhedraPhi,pow(polyhedraPhi,2)],[-polyhedraPhi,2*polyhedraPhi,-pow(polyhedraPhi,2)],[-polyhedraPhi,-2*polyhedraPhi,pow(polyhedraPhi,2)],[-polyhedraPhi,-2*polyhedraPhi,-pow(polyhedraPhi,2)],[(2+polyhedraPhi),0,pow(polyhedraPhi,2)],[(2+polyhedraPhi),0,-pow(polyhedraPhi,2)],[-(2+polyhedraPhi),0,pow(polyhedraPhi,2)],[-(2+polyhedraPhi),0,-pow(polyhedraPhi,2)],[pow(polyhedraPhi,2),(2+polyhedraPhi),0],[pow(polyhedraPhi,2),-(2+polyhedraPhi),0],[-pow(polyhedraPhi,2),(2+polyhedraPhi),0],[-pow(polyhedraPhi,2),-(2+polyhedraPhi),0],[0,pow(polyhedraPhi,2),(2+polyhedraPhi)],[0,pow(polyhedraPhi,2),-(2+polyhedraPhi)],[0,-pow(polyhedraPhi,2),(2+polyhedraPhi)],[0,-pow(polyhedraPhi,2),-(2+polyhedraPhi)]]/2;
rhombicosidodecahedron_edges=[[56,40],[40,24],[24,0],[0,56],[24,48],[48,26],[26,2],[2,0],[58,2],[26,42],[42,58],[42,18],[18,22],[22,46],[46,58],[38,46],[22,55],[38,55],[38,14],[14,15],[15,39],[39,55],[12,14],[12,13],[13,15],[13,37],[37,54],[54,36],[36,12],[54,20],[20,44],[44,36],[44,56],[16,40],[20,16],[28,4],[4,6],[6,30],[30,50],[50,28],[6,2],[6,58],[30,46],[30,38],[4,0],[4,56],[28,44],[28,36],[50,12],[50,14],[53,34],[34,10],[10,11],[11,35],[35,53],[18,53],[42,34],[26,34],[48,10],[9,8],[8,32],[32,52],[52,33],[33,9],[11,9],[10,8],[48,8],[24,32],[40,32],[16,52],[21,17],[17,41],[41,57],[57,45],[45,21],[33,41],[17,52],[17,16],[21,20],[54,21],[37,45],[51,29],[29,5],[5,7],[7,31],[31,51],[5,57],[29,45],[29,37],[13,51],[15,51],[39,31],[59,43],[43,19],[19,23],[23,47],[47,59],[7,59],[31,47],[39,47],[55,23],[22,23],[18,19],[53,19],[43,35],[1,25],[25,49],[49,27],[27,3],[3,1],[49,9],[49,11],[25,33],[25,41],[1,57],[1,5],[3,59],[3,7],[27,43],[27,35]];
rhombicosidodecahedron_adjacent_vertices=[[56,2,24,4],[5,3,57,25],[0,6,58,26],[27,1,7,59],[0,56,6,28],[1,57,7,29],[30,2,4,58],[31,5,3,59],[48,9,32,10],[33,49,11,8],[48,34,11,8],[9,49,35,10],[13,50,36,14],[15,12,51,37],[15,12,38,50],[51,13,39,14],[52,20,17,40],[52,16,21,41],[19,53,42,22],[53,18,43,23],[16,21,54,44],[45,20,17,54],[46,18,55,23],[19,22,55,47],[0,48,32,40],[33,1,49,41],[48,34,2,42],[49,35,3,43],[50,36,4,44],[51,45,37,5],[46,38,50,6],[51,39,7,47],[52,24,40,8],[9,52,25,41],[53,42,10,26],[27,53,43,11],[12,54,28,44],[45,13,54,29],[30,46,55,14],[15,31,55,47],[16,56,32,24],[33,17,57,25],[34,18,58,26],[27,19,35,59],[20,56,36,28],[37,57,21,29],[30,38,22,58],[31,39,23,59],[24,10,26,8],[27,9,25,11],[30,12,28,14],[15,31,13,29],[33,16,17,32],[19,34,35,18],[37,20,21,36],[38,39,22,23],[0,40,4,44],[45,1,5,41],[46,2,42,6],[3,43,7,47]];
rhombicosidodecahedron_triangle_faces=[[32,24,40],[52,16,17],[21,20,54],[44,28,36],[56,0,4],[2,58,6],[26,34,42],[46,38,30],[50,14,12],[15,51,13],[37,29,45],[57,5,1],[41,25,33],[48,8,10],[9,49,11],[27,43,35],[53,19,18],[3,7,59],[47,31,39],[22,23,55]];
rhombicosidodecahedron_square_faces=[[23,22,18,19],[18,42,34,53],[34,26,48,10],[48,24,32,8],[32,40,16,52],[16,20,21,17],[21,54,37,45],[37,13,51,29],[51,15,39,31],[39,55,23,47],[55,38,46,22],[46,30,6,58],[6,4,0,2],[0,56,40,24],[52,17,41,33],[41,57,1,25],[1,5,7,3],[7,31,47,59],[33,25,49,9],[49,27,35,11],[35,43,19,53],[38,14,50,30],[50,12,36,28],[36,54,20,44],[44,56,4,28],[2,26,42,58],[59,43,27,3],[29,5,57,45],[15,13,12,14],[10,8,9,11]];
rhombicosidodecahedron_pentagon_faces=[[46,58,42,18,22],[53,34,10,11,35],[41,17,21,45,57],[54,36,12,13,37],[4,6,30,50,28],[0,24,48,26,2],[25,1,3,27,49],[5,29,51,31,7],[14,38,55,39,15],[19,43,59,47,23],[9,8,32,52,33],[40,56,44,20,16]];
rhombicosidodecahedron_faces=concat(rhombicosidodecahedron_triangle_faces,rhombicosidodecahedron_square_faces,rhombicosidodecahedron_pentagon_faces);
polyhedraSDx=pow((polyhedraPhi+sqrt(polyhedraPhi-5/27))/2,1/3)+pow((polyhedraPhi-sqrt(polyhedraPhi-5/27))/2,1/3);
polyhedraSDc0=polyhedraPhi*sqrt(3-pow(polyhedraSDx,2))/2;
polyhedraSDc1=polyhedraSDx*polyhedraPhi*sqrt(3-pow(polyhedraSDx,2))/2;
polyhedraSDc2=polyhedraPhi*sqrt((polyhedraSDx-1-(1/polyhedraSDx))*polyhedraPhi)/2;
polyhedraSDc3=pow(polyhedraSDx,2)*polyhedraPhi*sqrt(3-pow(polyhedraSDx,2))/2;
polyhedraSDc4=polyhedraSDx*polyhedraPhi*sqrt((polyhedraSDx-1-(1/polyhedraSDx))*polyhedraPhi)/2;
polyhedraSDc5=polyhedraPhi*sqrt(1-polyhedraSDx+(polyhedraPhi+1)/polyhedraSDx)/2;
polyhedraSDc6=polyhedraPhi*sqrt(polyhedraSDx-polyhedraPhi+1)/2;
polyhedraSDc7=pow(polyhedraSDx,2)*polyhedraPhi*sqrt((polyhedraSDx-1-(1/polyhedraSDx))*polyhedraPhi)/2;
polyhedraSDc8=polyhedraSDx*polyhedraPhi*sqrt(1-polyhedraSDx+(polyhedraPhi+1)/polyhedraSDx)/2;
polyhedraSDc9=sqrt((polyhedraSDx+2)*polyhedraPhi+2)/2;
polyhedraSDc10=polyhedraSDx*sqrt(polyhedraSDx*(polyhedraPhi+1)-polyhedraPhi)/2;
polyhedraSDc11=sqrt(pow(polyhedraSDx,2)*(2*polyhedraPhi+1)-polyhedraPhi)/2;
polyhedraSDc12=polyhedraPhi*sqrt(pow(polyhedraSDx,2)+polyhedraSDx)/2;
polyhedraSDc13=pow(polyhedraPhi,2)*sqrt(polyhedraSDx*(polyhedraSDx+polyhedraPhi)+1)/(2*polyhedraSDx);
polyhedraSDc14=polyhedraPhi*sqrt(polyhedraSDx*(polyhedraSDx+polyhedraPhi)+1)/2;
snub_dodecahedron_vertices=[[polyhedraSDc2,polyhedraSDc1,-polyhedraSDc14],[polyhedraSDc2,-polyhedraSDc1,polyhedraSDc14],[-polyhedraSDc2,polyhedraSDc1,polyhedraSDc14],[-polyhedraSDc2,-polyhedraSDc1,-polyhedraSDc14],[polyhedraSDc14,polyhedraSDc2,-polyhedraSDc1],[polyhedraSDc14,-polyhedraSDc2,polyhedraSDc1],[-polyhedraSDc14,polyhedraSDc2,polyhedraSDc1],[-polyhedraSDc14,-polyhedraSDc2,-polyhedraSDc1],[polyhedraSDc1,polyhedraSDc14,-polyhedraSDc2],[polyhedraSDc1,-polyhedraSDc14,polyhedraSDc2],[-polyhedraSDc1,polyhedraSDc14,polyhedraSDc2],[-polyhedraSDc1,-polyhedraSDc14,-polyhedraSDc2],[polyhedraSDc0,polyhedraSDc8,-polyhedraSDc12],[polyhedraSDc0,-polyhedraSDc8,polyhedraSDc12],[-polyhedraSDc0,polyhedraSDc8,polyhedraSDc12],[-polyhedraSDc0,-polyhedraSDc8,-polyhedraSDc12],[polyhedraSDc12,polyhedraSDc0,-polyhedraSDc8],[polyhedraSDc12,-polyhedraSDc0,polyhedraSDc8],[-polyhedraSDc12,polyhedraSDc0,polyhedraSDc8],[-polyhedraSDc12,-polyhedraSDc0,-polyhedraSDc8],[polyhedraSDc8,polyhedraSDc12,-polyhedraSDc0],[polyhedraSDc8,-polyhedraSDc12,polyhedraSDc0],[-polyhedraSDc8,polyhedraSDc12,polyhedraSDc0],[-polyhedraSDc8,-polyhedraSDc12,-polyhedraSDc0],[polyhedraSDc7,polyhedraSDc6,-polyhedraSDc11],[polyhedraSDc7,-polyhedraSDc6,polyhedraSDc11],[-polyhedraSDc7,polyhedraSDc6,polyhedraSDc11],[-polyhedraSDc7,-polyhedraSDc6,-polyhedraSDc11],[polyhedraSDc11,polyhedraSDc7,-polyhedraSDc6],[polyhedraSDc11,-polyhedraSDc7,polyhedraSDc6],[-polyhedraSDc11,polyhedraSDc7,polyhedraSDc6],[-polyhedraSDc11,-polyhedraSDc7,-polyhedraSDc6],[polyhedraSDc6,polyhedraSDc11,-polyhedraSDc7],[polyhedraSDc6,-polyhedraSDc11,polyhedraSDc7],[-polyhedraSDc6,polyhedraSDc11,polyhedraSDc7],[-polyhedraSDc6,-polyhedraSDc11,-polyhedraSDc7],[polyhedraSDc3,polyhedraSDc4,polyhedraSDc13],[polyhedraSDc3,-polyhedraSDc4,-polyhedraSDc13],[-polyhedraSDc3,polyhedraSDc4,-polyhedraSDc13],[-polyhedraSDc3,-polyhedraSDc4,polyhedraSDc13],[polyhedraSDc13,polyhedraSDc3,polyhedraSDc4],[polyhedraSDc13,-polyhedraSDc3,-polyhedraSDc4],[-polyhedraSDc13,polyhedraSDc3,-polyhedraSDc4],[-polyhedraSDc13,-polyhedraSDc3,polyhedraSDc4],[polyhedraSDc4,polyhedraSDc13,polyhedraSDc3],[polyhedraSDc4,-polyhedraSDc13,-polyhedraSDc3],[-polyhedraSDc4,polyhedraSDc13,-polyhedraSDc3],[-polyhedraSDc4,-polyhedraSDc13,polyhedraSDc3],[polyhedraSDc9,polyhedraSDc5,polyhedraSDc10],[polyhedraSDc9,-polyhedraSDc5,-polyhedraSDc10],[-polyhedraSDc9,polyhedraSDc5,-polyhedraSDc10],[-polyhedraSDc9,-polyhedraSDc5,polyhedraSDc10],[polyhedraSDc10,polyhedraSDc9,polyhedraSDc5],[polyhedraSDc10,-polyhedraSDc9,-polyhedraSDc5],[-polyhedraSDc10,polyhedraSDc9,-polyhedraSDc5],[-polyhedraSDc10,-polyhedraSDc9,polyhedraSDc5],[polyhedraSDc5,polyhedraSDc10,polyhedraSDc9],[polyhedraSDc5,-polyhedraSDc10,-polyhedraSDc9],[-polyhedraSDc5,polyhedraSDc10,-polyhedraSDc9],[-polyhedraSDc5,-polyhedraSDc10,polyhedraSDc9]];
snub_dodecahedron_edges=[[30,26],[26,2],[2,1],[1,25],[25,29],[39,13],[13,33],[33,21],[30,18],[18,51],[51,59],[6,43],[43,55],[55,47],[47,9],[9,21],[30,22],[22,46],[21,53],[53,49],[56,48],[48,17],[17,29],[29,21],[21,45],[33,29],[29,5],[5,4],[4,28],[28,32],[17,5],[5,41],[41,49],[49,37],[37,3],[23,11],[11,45],[45,53],[53,41],[41,4],[25,33],[33,9],[9,11],[11,35],[35,27],[55,59],[59,13],[13,25],[25,17],[17,40],[11,47],[47,59],[59,39],[39,2],[2,14],[13,1],[1,36],[36,56],[56,44],[44,8],[16,4],[4,40],[40,48],[48,36],[36,2],[1,39],[39,51],[51,43],[43,7],[7,19],[52,56],[56,14],[14,26],[26,18],[18,43],[36,14],[14,34],[34,22],[22,54],[54,50],[26,34],[34,10],[10,8],[8,32],[32,24],[22,10],[10,44],[44,52],[52,40],[40,5],[48,52],[52,20],[20,32],[32,12],[12,38],[18,6],[6,42],[42,50],[50,38],[38,0],[34,30],[30,6],[6,7],[7,31],[31,35],[51,55],[55,23],[23,35],[35,15],[15,37],[47,23],[23,31],[31,19],[19,50],[50,58],[9,45],[45,57],[57,37],[37,0],[0,12],[42,19],[19,27],[27,15],[15,57],[57,53],[31,27],[27,3],[3,0],[0,24],[24,28],[15,3],[3,38],[38,58],[58,46],[46,10],[7,42],[42,54],[54,46],[46,8],[8,20],[44,20],[20,28],[28,16],[16,49],[49,57],[41,16],[16,24],[24,12],[12,58],[58,54]];
snub_dodecahedron_adjacent_vertices=[[24,37,38,12,3],[25,13,2,39,36],[14,1,39,26,36],[0,37,38,27,15],[5,28,41,16,40],[29,41,17,40,4],[42,7,18,43,30],[42,6,31,43,19],[10,20,46,32,44],[21,33,45,11,47],[46,34,22,44,8],[9,45,35,23,47],[0,24,38,32,58],[25,1,33,59,39],[56,2,34,26,36],[37,57,27,3,35],[24,28,41,49,4],[5,25,29,48,40],[6,43,26,30,51],[42,27,7,50,31],[52,28,32,44,8],[29,33,9,53,45],[10,46,34,54,30],[35,31,11,55,47],[0,28,32,12,16],[29,1,33,13,17],[14,2,34,18,30],[3,35,31,19,15],[24,20,32,16,4],[5,25,21,33,17],[6,34,22,18,26],[27,7,35,23,19],[24,20,28,12,8],[25,29,21,9,13],[10,14,22,26,30],[27,31,11,23,15],[56,14,1,2,48],[0,57,49,3,15],[0,12,3,50,58],[1,13,2,59,51],[5,52,17,48,4],[5,53,49,16,4],[6,54,7,50,19],[6,7,18,55,51],[10,56,52,20,8],[57,21,9,53,11],[10,22,54,8,58],[9,59,11,55,23],[56,52,17,40,36],[37,57,53,41,16],[42,38,54,58,19],[59,39,18,43,55],[56,20,44,48,40],[57,21,41,45,49],[42,46,22,50,58],[59,43,23,51,47],[52,14,44,48,36],[37,53,45,49,15],[46,38,12,54,50],[13,39,55,51,47]];
snub_dodecahedron_triangle_faces=[[51,39,59],[39,1,13],[59,39,13],[13,1,25],[55,51,59],[55,43,51],[7,6,43],[19,42,7],[43,18,51],[6,18,43],[42,6,7],[50,42,19],[50,54,42],[58,54,50],[38,58,50],[12,58,38],[0,12,38],[0,24,12],[24,32,12],[24,28,32],[16,28,24],[16,4,28],[16,41,4],[4,41,5],[5,40,4],[5,17,40],[5,29,17],[29,25,17],[29,33,25],[33,13,25],[1,39,2],[36,1,2],[14,36,2],[56,36,14],[48,36,56],[52,48,56],[40,48,52],[40,17,48],[56,44,52],[20,52,44],[20,44,8],[32,20,8],[28,20,32],[8,44,10],[8,10,46],[46,10,22],[46,22,54],[46,54,58],[10,34,22],[22,34,30],[30,34,26],[30,26,18],[30,18,6],[34,14,26],[14,2,26],[49,41,16],[49,53,41],[57,53,49],[57,45,53],[45,21,53],[45,9,21],[9,33,21],[21,33,29],[11,9,45],[11,47,9],[23,55,47],[47,55,59],[47,11,23],[35,23,11],[31,23,35],[27,31,35],[19,31,27],[19,7,31],[37,57,49],[37,15,57],[38,3,0],[3,27,15],[27,35,15],[3,15,37],[3,37,0]];
snub_dodecahedron_pentagon_faces=[[14,34,10,44,56],[39,51,18,26,2],[6,42,54,22,30],[46,58,12,32,8],[52,20,28,4,40],[36,48,17,25,1],[13,33,9,47,59],[7,43,55,23,31],[38,50,19,27,3],[37,49,16,24,0],[15,35,11,45,57],[53,21,29,5,41]];
snub_dodecahedron_faces=concat(snub_dodecahedron_triangle_faces,snub_dodecahedron_pentagon_faces);
truncated_icosidodecahedron_vertices=[[1/polyhedraPhi,1/polyhedraPhi,(3+polyhedraPhi)],[1/polyhedraPhi,1/polyhedraPhi,-(3+polyhedraPhi)],[1/polyhedraPhi,-1/polyhedraPhi,(3+polyhedraPhi)],[1/polyhedraPhi,-1/polyhedraPhi,-(3+polyhedraPhi)],[-1/polyhedraPhi,1/polyhedraPhi,(3+polyhedraPhi)],[-1/polyhedraPhi,1/polyhedraPhi,-(3+polyhedraPhi)],[-1/polyhedraPhi,-1/polyhedraPhi,(3+polyhedraPhi)],[-1/polyhedraPhi,-1/polyhedraPhi,-(3+polyhedraPhi)],[(3+polyhedraPhi),1/polyhedraPhi,1/polyhedraPhi],[(3+polyhedraPhi),1/polyhedraPhi,-1/polyhedraPhi],[(3+polyhedraPhi),-1/polyhedraPhi,1/polyhedraPhi],[(3+polyhedraPhi),-1/polyhedraPhi,-1/polyhedraPhi],[-(3+polyhedraPhi),1/polyhedraPhi,1/polyhedraPhi],[-(3+polyhedraPhi),1/polyhedraPhi,-1/polyhedraPhi],[-(3+polyhedraPhi),-1/polyhedraPhi,1/polyhedraPhi],[-(3+polyhedraPhi),-1/polyhedraPhi,-1/polyhedraPhi],[1/polyhedraPhi,(3+polyhedraPhi),1/polyhedraPhi],[1/polyhedraPhi,(3+polyhedraPhi),-1/polyhedraPhi],[1/polyhedraPhi,-(3+polyhedraPhi),1/polyhedraPhi],[1/polyhedraPhi,-(3+polyhedraPhi),-1/polyhedraPhi],[-1/polyhedraPhi,(3+polyhedraPhi),1/polyhedraPhi],[-1/polyhedraPhi,(3+polyhedraPhi),-1/polyhedraPhi],[-1/polyhedraPhi,-(3+polyhedraPhi),1/polyhedraPhi],[-1/polyhedraPhi,-(3+polyhedraPhi),-1/polyhedraPhi],[2/polyhedraPhi,polyhedraPhi,(1+2*polyhedraPhi)],[2/polyhedraPhi,polyhedraPhi,-(1+2*polyhedraPhi)],[2/polyhedraPhi,-polyhedraPhi,(1+2*polyhedraPhi)],[2/polyhedraPhi,-polyhedraPhi,-(1+2*polyhedraPhi)],[-2/polyhedraPhi,polyhedraPhi,(1+2*polyhedraPhi)],[-2/polyhedraPhi,polyhedraPhi,-(1+2*polyhedraPhi)],[-2/polyhedraPhi,-polyhedraPhi,(1+2*polyhedraPhi)],[-2/polyhedraPhi,-polyhedraPhi,-(1+2*polyhedraPhi)],[(1+2*polyhedraPhi),2/polyhedraPhi,polyhedraPhi],[(1+2*polyhedraPhi),2/polyhedraPhi,-polyhedraPhi],[(1+2*polyhedraPhi),-2/polyhedraPhi,polyhedraPhi],[(1+2*polyhedraPhi),-2/polyhedraPhi,-polyhedraPhi],[-(1+2*polyhedraPhi),2/polyhedraPhi,polyhedraPhi],[-(1+2*polyhedraPhi),2/polyhedraPhi,-polyhedraPhi],[-(1+2*polyhedraPhi),-2/polyhedraPhi,polyhedraPhi],[-(1+2*polyhedraPhi),-2/polyhedraPhi,-polyhedraPhi],[polyhedraPhi,(1+2*polyhedraPhi),2/polyhedraPhi],[polyhedraPhi,(1+2*polyhedraPhi),-2/polyhedraPhi],[polyhedraPhi,-(1+2*polyhedraPhi),2/polyhedraPhi],[polyhedraPhi,-(1+2*polyhedraPhi),-2/polyhedraPhi],[-polyhedraPhi,(1+2*polyhedraPhi),2/polyhedraPhi],[-polyhedraPhi,(1+2*polyhedraPhi),-2/polyhedraPhi],[-polyhedraPhi,-(1+2*polyhedraPhi),2/polyhedraPhi],[-polyhedraPhi,-(1+2*polyhedraPhi),-2/polyhedraPhi],[1/polyhedraPhi,polyhedraPhiSq,(3*polyhedraPhi-1)],[1/polyhedraPhi,polyhedraPhiSq,-(3*polyhedraPhi-1)],[1/polyhedraPhi,-polyhedraPhiSq,(3*polyhedraPhi-1)],[1/polyhedraPhi,-polyhedraPhiSq,-(3*polyhedraPhi-1)],[-1/polyhedraPhi,polyhedraPhiSq,(3*polyhedraPhi-1)],[-1/polyhedraPhi,polyhedraPhiSq,-(3*polyhedraPhi-1)],[-1/polyhedraPhi,-polyhedraPhiSq,(3*polyhedraPhi-1)],[-1/polyhedraPhi,-polyhedraPhiSq,-(3*polyhedraPhi-1)],[(3*polyhedraPhi-1),1/polyhedraPhi,polyhedraPhiSq],[(3*polyhedraPhi-1),1/polyhedraPhi,-polyhedraPhiSq],[(3*polyhedraPhi-1),-1/polyhedraPhi,polyhedraPhiSq],[(3*polyhedraPhi-1),-1/polyhedraPhi,-polyhedraPhiSq],[-(3*polyhedraPhi-1),1/polyhedraPhi,polyhedraPhiSq],[-(3*polyhedraPhi-1),1/polyhedraPhi,-polyhedraPhiSq],[-(3*polyhedraPhi-1),-1/polyhedraPhi,polyhedraPhiSq],[-(3*polyhedraPhi-1),-1/polyhedraPhi,-polyhedraPhiSq],[polyhedraPhiSq,(3*polyhedraPhi-1),1/polyhedraPhi],[polyhedraPhiSq,(3*polyhedraPhi-1),-1/polyhedraPhi],[polyhedraPhiSq,-(3*polyhedraPhi-1),1/polyhedraPhi],[polyhedraPhiSq,-(3*polyhedraPhi-1),-1/polyhedraPhi],[-polyhedraPhiSq,(3*polyhedraPhi-1),1/polyhedraPhi],[-polyhedraPhiSq,(3*polyhedraPhi-1),-1/polyhedraPhi],[-polyhedraPhiSq,-(3*polyhedraPhi-1),1/polyhedraPhi],[-polyhedraPhiSq,-(3*polyhedraPhi-1),-1/polyhedraPhi],[(2*polyhedraPhi-1),2,(2+polyhedraPhi)],[(2*polyhedraPhi-1),2,-(2+polyhedraPhi)],[(2*polyhedraPhi-1),-2,(2+polyhedraPhi)],[(2*polyhedraPhi-1),-2,-(2+polyhedraPhi)],[-(2*polyhedraPhi-1),2,(2+polyhedraPhi)],[-(2*polyhedraPhi-1),2,-(2+polyhedraPhi)],[-(2*polyhedraPhi-1),-2,(2+polyhedraPhi)],[-(2*polyhedraPhi-1),-2,-(2+polyhedraPhi)],[(2+polyhedraPhi),(2*polyhedraPhi-1),2],[(2+polyhedraPhi),(2*polyhedraPhi-1),-2],[(2+polyhedraPhi),-(2*polyhedraPhi-1),2],[(2+polyhedraPhi),-(2*polyhedraPhi-1),-2],[-(2+polyhedraPhi),(2*polyhedraPhi-1),2],[-(2+polyhedraPhi),(2*polyhedraPhi-1),-2],[-(2+polyhedraPhi),-(2*polyhedraPhi-1),2],[-(2+polyhedraPhi),-(2*polyhedraPhi-1),-2],[2,(2+polyhedraPhi),(2*polyhedraPhi-1)],[2,(2+polyhedraPhi),-(2*polyhedraPhi-1)],[2,-(2+polyhedraPhi),(2*polyhedraPhi-1)],[2,-(2+polyhedraPhi),-(2*polyhedraPhi-1)],[-2,(2+polyhedraPhi),(2*polyhedraPhi-1)],[-2,(2+polyhedraPhi),-(2*polyhedraPhi-1)],[-2,-(2+polyhedraPhi),(2*polyhedraPhi-1)],[-2,-(2+polyhedraPhi),-(2*polyhedraPhi-1)],[polyhedraPhi,3,2*polyhedraPhi],[polyhedraPhi,3,-2*polyhedraPhi],[polyhedraPhi,-3,2*polyhedraPhi],[polyhedraPhi,-3,-2*polyhedraPhi],[-polyhedraPhi,3,2*polyhedraPhi],[-polyhedraPhi,3,-2*polyhedraPhi],[-polyhedraPhi,-3,2*polyhedraPhi],[-polyhedraPhi,-3,-2*polyhedraPhi],[2*polyhedraPhi,polyhedraPhi,3],[2*polyhedraPhi,polyhedraPhi,-3],[2*polyhedraPhi,-polyhedraPhi,3],[2*polyhedraPhi,-polyhedraPhi,-3],[-2*polyhedraPhi,polyhedraPhi,3],[-2*polyhedraPhi,polyhedraPhi,-3],[-2*polyhedraPhi,-polyhedraPhi,3],[-2*polyhedraPhi,-polyhedraPhi,-3],[3,2*polyhedraPhi,polyhedraPhi],[3,2*polyhedraPhi,-polyhedraPhi],[3,-2*polyhedraPhi,polyhedraPhi],[3,-2*polyhedraPhi,-polyhedraPhi],[-3,2*polyhedraPhi,polyhedraPhi],[-3,2*polyhedraPhi,-polyhedraPhi],[-3,-2*polyhedraPhi,polyhedraPhi],[-3,-2*polyhedraPhi,-polyhedraPhi]]/(2*polyhedraPhi-2);
truncated_icosidodecahedron_edges=[[0,24],[24,72],[72,104],[104,56],[56,58],[58,106],[106,74],[74,26],[26,2],[2,0],[4,6],[6,30],[30,78],[78,110],[110,62],[62,60],[60,108],[108,76],[76,28],[28,4],[102,54],[54,50],[50,98],[98,90],[90,42],[42,18],[18,22],[22,46],[46,94],[94,102],[114,82],[82,34],[34,10],[10,11],[11,35],[35,83],[83,115],[115,67],[67,66],[66,114],[32,80],[80,112],[112,64],[64,65],[65,113],[113,81],[81,33],[33,9],[9,8],[8,32],[86,118],[118,70],[70,71],[71,119],[119,87],[87,39],[39,15],[15,14],[14,38],[38,86],[68,116],[116,84],[84,36],[36,12],[12,13],[13,37],[37,85],[85,117],[117,69],[69,68],[48,52],[52,100],[100,92],[92,44],[44,20],[20,16],[16,40],[40,88],[88,96],[96,48],[51,55],[55,103],[103,95],[95,47],[47,23],[23,19],[19,43],[43,91],[91,99],[99,51],[73,25],[25,1],[1,3],[3,27],[27,75],[75,107],[107,59],[59,57],[57,105],[105,73],[109,61],[61,63],[63,111],[111,79],[79,31],[31,7],[7,5],[5,29],[29,77],[77,109],[21,45],[45,93],[93,101],[101,53],[53,49],[49,97],[97,89],[89,41],[41,17],[17,21],[4,0],[6,2],[30,54],[78,102],[110,86],[62,38],[60,36],[108,84],[76,100],[28,52],[24,48],[72,96],[104,80],[56,32],[58,34],[106,82],[74,98],[26,50],[94,118],[70,46],[22,23],[18,19],[42,66],[90,114],[67,43],[115,91],[83,107],[35,59],[11,9],[10,8],[33,57],[81,105],[113,89],[41,65],[40,64],[112,88],[71,47],[119,95],[87,111],[39,63],[13,15],[12,14],[37,61],[85,109],[117,93],[69,45],[68,44],[116,92],[77,101],[29,53],[49,25],[97,73],[5,1],[7,3],[31,55],[79,103],[51,27],[99,75],[20,21],[16,17]];
truncated_icosidodecahedron_adjacent_vertices=[[2,24,4],[5,3,25],[0,6,26],[27,1,7],[0,6,28],[1,7,29],[30,2,4],[31,5,3],[9,32,10],[33,11,8],[34,11,8],[9,35,10],[13,36,14],[15,12,37],[15,12,38],[13,39,14],[20,17,40],[16,21,41],[19,42,22],[18,43,23],[16,21,44],[45,20,17],[46,18,23],[19,22,47],[0,48,72],[1,49,73],[74,2,50],[51,3,75],[52,76,4],[5,53,77],[78,6,54],[79,7,55],[56,80,8],[81,9,57],[82,10,58],[83,11,59],[84,12,60],[13,85,61],[86,14,62],[15,63,87],[16,88,64],[89,17,65],[66,90,18],[19,67,91],[20,68,92],[21,93,69],[70,22,94],[71,95,23],[96,52,24],[53,97,25],[54,98,26],[99,27,55],[48,100,28],[49,101,29],[102,30,50],[51,103,31],[104,32,58],[33,105,59],[34,56,106],[107,35,57],[108,36,62],[63,37,109],[60,38,110],[111,39,61],[112,40,65],[64,113,41],[114,67,42],[66,115,43],[69,116,44],[117,45,68],[118,46,71],[70,119,47],[96,104,24],[105,25,97],[106,26,98],[27,99,107],[100,108,28],[101,109,29],[30,102,110],[31,103,111],[32,104,112],[33,105,113],[114,34,106],[115,35,107],[36,108,116],[117,37,109],[118,38,110],[119,39,111],[96,40,112],[97,41,113],[114,42,98],[99,115,43],[100,44,116],[45,117,101],[102,46,118],[103,119,47],[48,88,72],[49,89,73],[74,50,90],[51,75,91],[52,76,92],[53,93,77],[78,54,94],[79,55,95],[56,72,80],[81,57,73],[82,74,58],[83,75,59],[84,60,76],[85,61,77],[78,86,62],[63,87,79],[88,64,80],[81,89,65],[66,82,90],[67,83,91],[84,68,92],[85,93,69],[70,86,94],[71,87,95]];
truncated_icosidodecahedron_square_faces=[[94,46,70,118],[30,54,102,78],[110,86,38,62],[71,47,95,119],[22,18,19,23],[79,103,55,31],[39,87,111,63],[12,14,15,13],[85,37,61,109],[101,77,29,53],[1,5,7,3],[27,51,99,75],[115,91,43,67],[66,42,90,114],[98,50,26,74],[2,6,4,0],[52,28,76,100],[108,60,36,84],[92,116,68,44],[69,117,93,45],[16,20,21,17],[112,88,40,64],[56,104,80,32],[82,106,58,34],[10,8,9,11],[83,35,59,107],[33,81,105,57],[73,97,49,25],[113,65,41,89],[24,48,96,72]];
truncated_icosidodecahedron_hexagon_faces=[[109,77,101,93,117,85],[37,13,15,39,63,61],[87,119,95,103,79,111],[31,55,51,27,3,7],[25,49,53,29,5,1],[73,105,81,113,89,97],[41,65,64,40,16,17],[21,20,44,68,69,45],[92,100,76,108,84,116],[14,12,36,60,62,38],[47,71,70,46,22,23],[43,19,18,42,66,67],[75,99,91,115,83,107],[59,35,11,9,33,57],[114,90,98,74,106,82],[10,34,58,56,32,8],[112,80,104,72,96,88],[48,24,0,4,28,52],[6,2,26,50,54,30],[78,102,94,118,86,110]];
truncated_icosidodecahedron_decagon_faces=[[0,24,72,104,56,58,106,74,26,2],[4,6,30,78,110,62,60,108,76,28],[102,54,50,98,90,42,18,22,46,94],[114,82,34,10,11,35,83,115,67,66],[32,80,112,64,65,113,81,33,9,8],[86,118,70,71,119,87,39,15,14,38],[68,116,84,36,12,13,37,85,117,69],[48,52,100,92,44,20,16,40,88,96],[51,55,103,95,47,23,19,43,91,99],[73,25,1,3,27,75,107,59,57,105],[109,61,63,111,79,31,7,5,29,77],[21,45,93,101,53,49,97,89,41,17]];
truncated_icosidodecahedron_faces=concat(truncated_icosidodecahedron_square_faces,truncated_icosidodecahedron_hexagon_faces,truncated_icosidodecahedron_decagon_faces);
