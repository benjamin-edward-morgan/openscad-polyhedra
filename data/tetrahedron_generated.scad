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
