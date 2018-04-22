#!/bin/bash -e

function render_png() {
  SHAPE=$1  
  echo -e "rendering png/polyhedra.png"  
  openscad \
    --camera=75,75,-75,0,0,0 \
    --imgsize=1024,768 \
    --projection=ortho \
    --colorscheme=Tomorrow \
    -D 'SHAPE="'${SHAPE}'"' \
    -o png/polyhedra.png \
    polyhedra.scad   
}

function render_stl() {
  SHAPE=$1
  echo -e "rendering stl/polyhedra.stl"
  openscad \
    -D 'SHAPE="'${SHAPE}'"' \
    -o stl/polyhedra.stl \
    polyhedra.scad 
}

mkdir -p png
mkdir -p stl

for SHAPE in "all"; do
  render_png $SHAPE
done

for SHAPE in "all"; do
  render_stl $SHAPE
done
