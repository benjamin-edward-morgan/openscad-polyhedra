/*

To the extent possible under law, Benjamin E Morgan has waived all copyright and related or neighboring rights to openscad-polyhedra. This work is published in the public domain.

Original Source: https://github.com/benjamin-edward-morgan/openscad-polyhedra

The modules included here utilize pollyhedra.scad to demonstrate the arrangement of faces, edges and vertices and the construction of solid polyhedra for all shapes included in polyhedra.scad 

*/

include<polyhedra.scad>;

//RGB colors for examples
polyhedraEdgeColor = [227,26,28]/255;
polyhedraVertexColor = [31,120,180]/255;
polyhedraFaceColor1 = [178,223,138]/255;
polyhedraFaceColor2 = [251,154,153]/255;
polyhedraFaceColor3 = [166,206,227]/255;
polyhedraSolidColor = [253,191,111]/255;

//This font is used in the enumerated examples for edges, vertices and faces. If you don't have this font installed, choose a font from the Font List in the OpenSCAD Help menu.
polyhedraEnumeratedFont = "Consolas";

//Uncomment a display mode to change how the shapes are rendered
polyhedraDisplayMode = "enumerated";
//polyhedraDisplayMode = "wireframe";
//polyhedraDisplayMode = "solid";

//Uncomment a display shape. The is one for each polyhedron included in polyhedra.scad. The layout arrangement shows all polyhedra.
//polyhedraDisplayShape = "layout";
//polyhedraDisplayShape = "tetrahedron";
//polyhedraDisplayShape = "octahedron";
polyhedraDisplayShape = "hexahedron";
//polyhedraDisplayShape = "icosahedron";
//polyhedraDisplayShape = "dodecahedron";
//polyhedraDisplayShape = "cubeoctahedron";
//polyhedraDisplayShape = "truncated_tetrahedron";
//polyhedraDisplayShape = "snub_cube";
//polyhedraDisplayShape = "rhombicuboctahedron";
//polyhedraDisplayShape = "truncated_hexahedron";
//polyhedraDisplayShape = "truncated_octahedron";
//polyhedraDisplayShape = "icosidodecahedron";
//polyhedraDisplayShape = "snub_dodecahedron";
//polyhedraDisplayShape = "rhombicosidodecahedron";
//polyhedraDisplayShape = "truncated_cuboctahedron";
//polyhedraDisplayShape = "truncated_icosahedron";
//polyhedraDisplayShape = "truncated_dodecahedron";
//polyhedraDisplayShape = "truncated_icosidodecahedron";

//Conditional scaling
polyhedraNoScale=false; 
//polyhedraNoScale=true;

if(polyhedraDisplayShape=="layout")
    conditional_scale(3) polyhedra_layout();
else if(polyhedraDisplayShape=="tetrahedron")
    conditional_scale(30) tetrahedron();
else if(polyhedraDisplayShape=="octahedron")
    conditional_scale(30) octahedron();
else if(polyhedraDisplayShape=="hexahedron")
    conditional_scale(25) hexahedron();
else if(polyhedraDisplayShape=="icosahedron")
    conditional_scale(20) icosahedron();
else if(polyhedraDisplayShape=="dodecahedron")
    conditional_scale(15) dodecahedron();
else if(polyhedraDisplayShape=="cubeoctahedron")
    conditional_scale(20) cubeoctahedron();
else if(polyhedraDisplayShape=="truncated_tetrahedron")
    conditional_scale(17) truncated_tetrahedron();
else if(polyhedraDisplayShape=="snub_cube")
    conditional_scale(14) snub_cube();
else if(polyhedraDisplayShape=="rhombicuboctahedron")
    conditional_scale(13) rhombicuboctahedron();
else if(polyhedraDisplayShape=="truncated_hexahedron")
    conditional_scale(12) truncated_hexahedron();
else if(polyhedraDisplayShape=="truncated_octahedron")
    conditional_scale(12) truncated_octahedron();
else if(polyhedraDisplayShape=="icosidodecahedron")
    conditional_scale(11) icosidodecahedron();
else if(polyhedraDisplayShape=="snub_dodecahedron")
    conditional_scale(9) snub_dodecahedron();
else if(polyhedraDisplayShape=="rhombicosidodecahedron")
    conditional_scale(9) rhombicosidodecahedron();
else if(polyhedraDisplayShape=="truncated_cuboctahedron")
    conditional_scale(8) truncated_cuboctahedron();
else if(polyhedraDisplayShape=="truncated_icosahedron")
    conditional_scale(8) truncated_icosahedron();
else if(polyhedraDisplayShape=="truncated_dodecahedron")
    conditional_scale(7) truncated_dodecahedron();
else if(polyhedraDisplayShape=="truncated_icosidodecahedron")
    conditional_scale(6) truncated_icosidodecahedron();
else echo(concat("unknown polyhedraDisplayShape: ", polyhedraDisplayName));

/***************************/
/** Test component shapes **/
/***************************/

/*
2d text with a line under it, so 6 and 9 can be more easily differentiated. 
*/
module underlined_text(text="abc", text_size=0.2) {
  scale(text_size)  
    text(text,font=polyhedraEnumeratedFont,size=1,valign="center",halign="center");
  translate([0,-text_size*0.6])
    square(size=[text_size*0.6*len(text),text_size/7],center=true);
}

/*
this module is used for the example vertices
i is the number displayed in "enumerated" mode
in "wireframe" mode a sphere is created instead
*/
module sample_vertex(i) {
    if(polyhedraDisplayMode=="enumerated")
        rotate(-90)
        linear_extrude(0.1) 
        underlined_text(text=str(i));
    else if(polyhedraDisplayMode=="wireframe")
        sphere(r=0.1,$fn=32);
}

/*
this module is used for example edges
i is the number displayed in "enumerated" mode
in "wireframe" mode a cylinder is created instead
*/
module sample_edge(i,h=2,r=0.05,$fn=16) {
    if(polyhedraDisplayMode=="enumerated")
        linear_extrude(height=h*0.7,center=true)
            translate([0.1,0,0])
            rotate(-90)
            underlined_text(str(i),text_size=0.1);
    else if(polyhedraDisplayMode=="wireframe")
        linear_extrude(height=h,center=true)
           circle(r=r);
} 

/*
this module is used to create an example face in "enumerated" mode
i is the number displayed on the face
n is the number of sides the face has
*/
module sample_face(i,n,r=3,h=0.1,t=0.1) {
    if(polyhedraDisplayMode=="enumerated")
        linear_extrude(height=h) {
            underlined_text(str(i),text_size=r/2) ;
            rotate(180/n-90)
            difference() {
              circle($fn=n,r=r);
              circle($fn=n,r=r-t);
            }
        }
}

/***************************************/
/** Polyhedra demonstration functions **/
/***************************************/

/*
applies a scale transformation to children only if noScale is false
*/
module conditional_scale(x) {
    if(polyhedraNoScale)
        children();
    else
        scale(x) children();
}

/*
creates a sample_vertex for each vertex in verts
the adjacents array is used to orient the vertices correctly 
*/
module show_vertices(verts,adjacents) {
    for(i=[0:len(verts)-1])
    orient_vertex(verts[i], verts[adjacents[i][0]]) 
    sample_vertex(i);
}

/*
creates a sample_edge for edge in edges and orients it
*/
module show_edges(verts, edges,$fn=16) {
    for(i=[0:len(edges)-1]) {
        a = verts[edges[i][0]];
        b = verts[edges[i][1]];        
        
        orient_edge(a,b) {
            sample_edge(i=i,h=norm(a-b));   
        }   
    }
}

/*
creates a sample_face for each face in faces and orients it 
*/
module show_faces(verts, faces) {
    for(i=[0:len(faces)-1]) {
        center = sum_verts(map_verts(verts,faces[i]))/len(faces[i]) ;
        r = norm(verts[faces[i][0]] - center) - 0.1;
        orient_face(map_verts(verts, faces[i]))
        sample_face(i=i, n=len(faces[i]), r=r); 
    }
}

/*
uses show_vertices, show_edges and show_faces to display all components of the polyhedra. Also renders a solid polyhedraon.
vertices is a vertices array 
edges is an edges array 
adjacent vertices is an adjacent_vertices array 
faces_array is an array of face arrays. Each set of faces is shown in a different color. For Example: [snub_dodecahedron_triangle_faces, snub_dodecahedron_pentagon_faces]
*/
module show_polyhedron(vertices, edges, adjacentVertices, facesArray) {
   
  echo(vertices=len(vertices));
  echo(edges=len(edges));
  echo(faces=len(concat_all(facesArray)));
    
  faceColorArray = [polyhedraFaceColor1, polyhedraFaceColor2, polyhedraFaceColor3];
    
  color(polyhedraVertexColor)    
  show_vertices(vertices,adjacentVertices);  

  color(polyhedraEdgeColor)
  show_edges(vertices, edges); 
    
  for(i=[0:min(len(faceColorArray),len(facesArray))-1])
      color(faceColorArray[i])
      show_faces(vertices, facesArray[i]);
    
  if(polyhedraDisplayMode=="enumerated") {
      r = norm(vertices[0]);
      s = (r-0.1)/r;
      color(polyhedraSolidColor)
      scale(s)
      polyhedron(points=vertices,faces=concat_all(facesArray));
  } else if (polyhedraDisplayMode=="solid") {
      color(polyhedraSolidColor)
      polyhedron(points=vertices,faces=concat_all(facesArray));
  }
}

/**********************/
/**Polyhedra examples**/
/**********************/

/*
an arrangement of all polyhedra
*/
module polyhedra_layout() {
    translate([0,-11,0]){  
        translate([6,0,0])
            tetrahedron();
        translate([3.5,0,0])
            octahedron();
        translate([1,0,0])
            hexahedron();
        translate([-1.5,0,0])
            icosahedron();
        translate([-4.5,0,0])
            dodecahedron();
    }
    
    translate([0,-6,0]) {
        translate([6.5,0,0])
            cubeoctahedron();
        translate([3.5,0,0])
            truncated_tetrahedron();
        translate([0,0,0])
             snub_cube();
        translate([-4,0,0])
            rhombicuboctahedron();
        translate([-8,0,0])
            truncated_hexahedron();
    }
    
    translate([0,0.5,0]) {
        translate([9,0,0])
            truncated_octahedron();
        translate([5,0,0])
            icosidodecahedron();
        translate([0.25,0,0])
            snub_dodecahedron();
        translate([-5,0,0])
            rhombicosidodecahedron();
        translate([-10.75,0,0])
            truncated_cuboctahedron();
    }
     
     translate([0,10,0]) {
         translate([6,-2,0])
             truncated_icosahedron();
         translate([-1,0,0])
             truncated_dodecahedron();
         translate([-10,2,0])
             truncated_icosidodecahedron();
     }
}

/*
each polyhedron 
*/
module tetrahedron() {
    echo("tetrahedron");
    show_polyhedron(
        tetrahedron_vertices,
        tetrahedron_edges,
        tetrahedron_adjacent_vertices,
        [tetrahedron_faces]
    );
}

module hexahedron() {
    echo("hexahedron");
    show_polyhedron(
        hexahedron_vertices,
        hexahedron_edges,
        hexahedron_adjacent_vertices,
        [hexahedron_faces]
    );
}

module octahedron() {
    echo("octahedron");
    show_polyhedron(
        octahedron_vertices,
        octahedron_edges,
        octahedron_adjacent_vertices,
        [octahedron_faces]
    );
}

module dodecahedron() {
    echo("dodecahedron");
    show_polyhedron(
        dodecahedron_vertices,
        dodecahedron_edges,
        dodecahedron_adjacent_vertices,
        [dodecahedron_faces]
    );
}

module icosahedron() {
    echo("icosahedron");
    show_polyhedron(
        icosahedron_vertices,
        icosahedron_edges,
        icosahedron_adjacent_vertices,
        [icosahedron_faces]
    );
}

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
