#!/bin/bash -e

openscad -v >/dev/null 2>&1 || { 
  printf "Please set up openscad so that it can be used in this script.\nSee https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Using_OpenSCAD_in_a_command_line_environment\n" 
  exit 1
}

function render_png() {
  SHAPE=$1  
  FILENAME="img/polyhedra_${SHAPE}.png"
  echo -e "rendering ${FILENAME}"  
  openscad \
    --camera=75,75,-75,0,0,0 \
    --imgsize=1024,768 \
    --projection=ortho \
    --colorscheme=Tomorrow \
    -D 'SHAPE="${SHAPE}"' \
    -o $FILENAME \
    polyhedra.scad   
}

function render_stl() {
  SHAPE=$1
  FILENAME="stl/polyhedra_${SHAPE}.stl"
  echo -e "rendering ${FILENAME}"
  openscad \
    -D 'SHAPE="${SHAPE}"' \
    -o $FILENAME \
    polyhedra.scad 
}

mkdir -p img
mkdir -p stl

for SHAPE in "all"; do
  render_png $SHAPE
done

for SHAPE in "all"; do
  render_stl $SHAPE
done
