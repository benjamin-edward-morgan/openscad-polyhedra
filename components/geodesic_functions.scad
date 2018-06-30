/**********************/
/**Geodesic functions**/
/**********************/

module sample_vert(i,adjacents,size=0.3,font="Consolas") {
    linear_extrude(size/3)
    text(str(i),font=font,size=size,valign="center",halign="center");
}

module orient_verts(verts,adjacents,n=1,r=0.1) {
    for(i=[0:len(verts)-1])
    orient_vertex(verts[i],verts[adjacents[i]])
    linear_extrude(0.1)
    text(str(i),font="Consolas",size=0.3,valign="center",halign="center");
}



module show_verts(verts,r=0.1,$fn=32) {
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
            rotate(-45)
            square(size=r);
        }     
} 

module show_edges(verts, edges,r=0.03,$fn=16) {
    for(i=[0:len(edges)-1]) {
        a = verts[edges[i][0]];
        b = verts[edges[i][1]];        
        
        orient_edge(a,b) {
            sample_edge(h=norm(a-b),r=r);   
        }   
    }
}