include<polyhedra.scad>;

polyhedraEdgeColor = [139/255,224/255,97/255]; //8BE061
polyhedraVertexColor = [92/255,76/255,77/255]; //5C4C4D
polyhedraFaceColor1 = [239/255,233/255,106/255]; //EFE96A
polyhedraFaceColor2 = [233/255,148/255,32/255];//E99420
polyhedraFaceColor3 = [193/255,75/255,49/255];//C14B31
polyhedraSolidColor = [135/255,190/255,181/255];//87BEB5

polyhedra_layout();
module polyhedra_layout() {
    row1 = [0,1.3,2.8,4.6,6]*2;
    scale(3) {
        translate([0,-9,0])
        for(i=[0:4])
            translate([-row1[i]+6,0,0])
            if(i==0)
                tetrahedron();
            else if(i==1)
                octahedron();
            else if(i==2)
                hexahedron();
            else if(i==3)
                icosahedron();
            else if(i==4)
                dodecahedron();
        
        translate([0,-5,0])
        for(i=[0:4])
            translate([i*-4+8,0,0])
            if(i==0)
                cubeoctahedron();
            else if(i==1)
                truncated_tetrahedron();
            else if(i==2)
                 snub_cube();
            else if(i==3)
                rhombicuboctahedron();
            else if(i==4)
                truncated_hexahedron();

        translate([0,0,0])
        for(i=[0:4])
            translate([i*-5+10,0,0])
            if(i==0)
                truncated_octahedron();
            else if(i==1)
                icosidodecahedron();
            else if(i==2)
                snub_dodecahedron();
            else if(i==3)
                rhombicosidodecahedron();
            else if(i==4)
                truncated_cuboctahedron();
            
         translate([0,8,0])   
         for(i=[0:2])
             translate([i*-8+8,0,0])
             if(i==0)
                 truncated_icosahedron();
             else if(i==1)
                 truncated_dodecahedron();
             else if(i==2)
                 truncated_icosidodecahedron();
     }
}

/**Test util functions**/

module show_verts(verts,r=0.1,$fn=32) {
    echo(vertices=len(verts));
    for(i=[0:len(verts)-1])
    translate(verts[i])
    //sphere(r=r);
    linear_extrude(0.1)
    text(str(i),font="Consolas",size=r*2,valign="center",halign="center");
}


module sample_vertex(i,r=0.1) {
    
    linear_extrude(0.1) {
    text(str(i),font="Consolas",size=r,valign="center",halign="center");
    if(i==6 || i==9)
       translate([0,-r*0.7])
       square(size=[r,r/6],center=true);
    }
    //sphere(r=r/3,$fn=32);
    
}

module show_vertices(verts,adjacents,r=0.40) {
    for(i=[0:len(verts)-1])
    orient_vertex(verts[i], verts[adjacents[i][0]]) 
    sample_vertex(i,r=r);
}

//sample_edge(h=1);
module sample_edge(h=2,r=0.05,$fn=16) {
    linear_extrude(height=h,center=true)
        union() {
            circle(r=r);
            //rotate(-45)
            //square(size=r);
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
            if(i==6 || i==9)
       translate([0,-0.4])
       square(size=[0.6,0.1],center=true);
        
        rotate(180/n-90)
        difference() {
          circle($fn=n,r=r);
          circle($fn=n,r=r-t);
        }
    }
}


//really, OpenSCAD ?
function concat_all(arrays, i=0, final_array=[]) = len(arrays) <= i ? final_array : concat_all(arrays, i+1, concat(arrays[i], final_array));

module show_polyhedron(vertices, edges, adjacentVertices, facesArray, allFaces) {
   
  echo(vertices=len(vertices));
  echo(edges=len(edges));
  echo(faces=len(facesArray));
  echo(radius=norm(vertices[0]));
    
  faceColorArray = [polyhedraFaceColor1, polyhedraFaceColor2, polyhedraFaceColor3];
    
  color(polyhedraVertexColor)    
  show_vertices(vertices,adjacentVertices);  

  color(polyhedraEdgeColor)
  show_edges(vertices, edges); 
    
  for(i=[0:min(len(faceColorArray),len(facesArray))-1])
      color(faceColorArray[i])
      show_faces(vertices, facesArray[i]);
    
  color(polyhedraSolidColor)
  scale(0.8)
  polyhedron(points=vertices,faces=concat_all(facesArray));
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

/**********************/
/**Polyhedra examples**/
/**********************/

//tetrahedron();
module tetrahedron() {
    echo("tetrahedron");
    show_polyhedron(
        tetrahedron_vertices,
        tetrahedron_edges,
        tetrahedron_adjacent_vertices,
        [tetrahedron_faces]
    );
}

//hexahedron();
module hexahedron() {
    echo("hexahedron");
    show_polyhedron(
        hexahedron_vertices,
        hexahedron_edges,
        hexahedron_adjacent_vertices,
        [hexahedron_faces]
    );
}

//octahedron();
module octahedron() {
    echo("octahedron");
    show_polyhedron(
        octahedron_vertices,
        octahedron_edges,
        octahedron_adjacent_vertices,
        [octahedron_faces]
    );
}

//dodecahedron();
module dodecahedron() {
    echo("dodecahedron");
    show_polyhedron(
        dodecahedron_vertices,
        dodecahedron_edges,
        dodecahedron_adjacent_vertices,
        [dodecahedron_faces]
    );
}

//icosahedron();
module icosahedron() {
    echo("icosahedron");
    show_polyhedron(
        icosahedron_vertices,
        icosahedron_edges,
        icosahedron_adjacent_vertices,
        [icosahedron_faces]
    );
}

//cubeoctahedron();
module cubeoctahedron() {
    echo("cubeoctahedron");
    show_polyhedron(
        cubeoctahedron_vertices,
        cubeoctahedron_edges,
        cubeoctahedron_adjacent_vertices,
        [cubeoctahedron_triangle_faces,
        cubeoctahedron_square_faces]
    ); 
}

//icosidodecahedron();
module icosidodecahedron() {
    echo("icosidodecahedron");
    show_polyhedron(
        icosidodecahedron_vertices,
        icosidodecahedron_edges,
        icosidodecahedron_adjacent_vertices,
        [icosidodecahedron_triangle_faces,
        icosidodecahedron_pentagon_faces]
    );
}

//truncated_tetrahedron();
module truncated_tetrahedron() {
    echo("truncated_tetrahedron");
    show_polyhedron(
        truncated_tetrahedron_vertices,
        truncated_tetrahedron_edges,
        truncated_tetrahedron_adjacent_vertices,
        [truncated_tetrahedron_triangle_faces,
        truncated_tetrahedron_hexagon_faces]
    );
}

//truncated_hexahedron();
module truncated_hexahedron() {
    echo("truncated_hexahedron");
    show_polyhedron(
        truncated_hexahedron_vertices,
        truncated_hexahedron_edges,
        truncated_hexahedron_adjacent_vertices,
        [truncated_hexahedron_triangle_faces,
        truncated_hexahedron_octagon_faces]
    );
}

//truncated_octahedron();
module truncated_octahedron() {
    echo("truncated_octahedron");
    show_polyhedron(
        truncated_octahedron_vertices,
        truncated_octahedron_edges,
        truncated_octahedron_adjacent_vertices,
        [truncated_octahedron_square_faces,
        truncated_octahedron_hexagon_faces]
    );
}


//rhombicuboctahedron();
module rhombicuboctahedron() {
    echo("rhombicuboctahedron");
    show_polyhedron(
        rhombicuboctahedron_vertices,
        rhombicuboctahedron_edges,
        rhombicuboctahedron_adjacent_vertices,
        [rhombicuboctahedron_triangle_faces,
        rhombicuboctahedron_square_faces]
    );
}

//truncated_cuboctahedron();
module truncated_cuboctahedron() {
    echo("truncated_cuboctahedron");
    show_polyhedron(
        truncated_cuboctahedron_vertices,
        truncated_cuboctahedron_edges,
        truncated_cuboctahedron_adjacent_vertices,
        [truncated_cuboctahedron_square_faces,
        truncated_cuboctahedron_hexagon_faces,
        truncated_cuboctahedron_octagon_faces]
    );
}

//snub_cube();
module snub_cube() {
    echo("snub_cube");
    show_polyhedron(
        snub_cube_vertices,
        snub_cube_edges,
        snub_cube_adjacent_vertices,
        [snub_cube_triangle_faces,
        snub_cube_square_faces]
    );
}


//truncated_dodecahedron();
module truncated_dodecahedron() {
    echo("truncated_dodecahedron");
    show_polyhedron(
        truncated_dodecahedron_vertices,
        truncated_dodecahedron_edges,
        truncated_dodecahedron_adjacent_vertices,
        [truncated_dodecahedron_triangle_faces,
        truncated_dodecahedron_decagon_faces]
    );
}


//truncated_icosahedron();
module truncated_icosahedron() {
    echo("truncated_icosahedron");
    show_polyhedron(
        truncated_icosahedron_vertices,
        truncated_icosahedron_edges,
        truncated_icosahedron_adjacent_vertices,
        [truncated_icosahedron_pentagon_faces,
        truncated_icosahedron_hexagon_faces]
    );
}

//rhombicosidodecahedron();
module rhombicosidodecahedron() {
    echo("rhombicosidodecahedron");
    show_polyhedron(
      rhombicosidodecahedron_vertices,
      rhombicosidodecahedron_edges,
      rhombicosidodecahedron_adjacent_vertices,
      [rhombicosidodecahedron_triangle_faces,
      rhombicosidodecahedron_square_faces,
      rhombicosidodecahedron_pentagon_faces]
    ); 
}

//snub_dodecahedron();
module snub_dodecahedron() {
    echo("snub_dodecahedron");
    show_polyhedron(
        snub_dodecahedron_vertices,
        snub_dodecahedron_edges,
        snub_dodecahedron_adjacent_vertices,
        [snub_dodecahedron_triangle_faces, 
        snub_dodecahedron_pentagon_faces]
    );
}

//truncated_icosidodecahedron();
module truncated_icosidodecahedron() {
    echo("truncated_icosidodecahedron");
    show_polyhedron(
        truncated_icosidodecahedron_vertices,
        truncated_icosidodecahedron_edges,
        truncated_icosidodecahedron_adjacent_vertices,
        [truncated_icosidodecahedron_square_faces,
        truncated_icosidodecahedron_hexagon_faces,
        truncated_icosidodecahedron_decagon_faces]);
 
}

