#!/bin/bash -e

openscad -v >/dev/null 2>&1 || {
  printf "Please set up openscad so that it can be used in this script.\nSee https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Using_OpenSCAD_in_a_command_line_environment\n"
  exit 1
}

magick -version >/dev/null 2>&1 || {
  printf "Please set up ImageMagick. You should be able to do this from your favorite package manager like Homebrew or apt-get."
  exit 1
}

function render_png() {
  SHAPE=$1
  FILENAME="img/polyhedra_${SHAPE}.png"
  echo -e "rendering ${FILENAME}"
  openscad \
    --camera=-0,0,0,55,0,25,160 \
    --imgsize=2048,1536 \
    --projection=p \
    --colorscheme="Tomorrow Night" \
    -D 'SHAPE="${SHAPE}"' \
    -o $FILENAME \
    polyhedra-tests.scad
}

function render_stl() {
  SHAPE=$1
  FILENAME="stl/polyhedra_${SHAPE}.stl"
  echo -e "rendering ${FILENAME}"
  openscad \
    -D 'SHAPE="${SHAPE}"' \
    -o $FILENAME \
    polyhedra-tests.scad
}

mkdir -p img
mkdir -p stl

for SHAPE in "all"; do
  render_png $SHAPE
done


##for SHAPE in "all"; do
##  render_stl $SHAPE
##done
