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
  MODE=$2
  FILENAME="img/polyhedra_${SHAPE}_${MODE}.png"
  echo -e "rendering ${FILENAME}"
  openscad \
    --camera=-0,0,0,55,0,25,160 \
    --imgsize=2048,1536 \
    --projection=p \
    --colorscheme="Tomorrow Night" \
    -D 'polyhedraDisplayShape="'${SHAPE}'"' \
    -D 'polyhedraDisplayMode="'${MODE}'"' \
    -o $FILENAME \
    polyhedra-tests.scad
}

function render_gif() {
  SHAPE=$1
  MODE=$2

  rm -f img/tmp/*

  for i in `seq 0 5 359`
  do
    PADDED=$(printf "%03d" $i)
    FILENAME="img/tmp/polyhedra_${SHAPE}_${MODE}_${PADDED}.png"
    echo -e "rendering ${FILENAME}"
    openscad \
      --camera=-0,0,0,55,0,$i,140 \
      --imgsize=512,384 \
      --projection=p \
      -D 'polyhedraDisplayShape="'${SHAPE}'"' \
      -D 'polyhedraDisplayMode="'${MODE}'"' \
      --colorscheme="Tomorrow Night" \
      -o $FILENAME \
      polyhedra-tests.scad
  done

  magick img/tmp/*.png img/polyhedra_${SHAPE}_${MODE}.gif

  rm -f img/tmp/*
}

function render_stl() {
  SHAPE=$1
  MODE=$2
  FILENAME="stl/polyhedra_${SHAPE}_${MODE}.stl"
  echo -e "rendering ${FILENAME}"
  openscad \
    -D 'polyhedraDisplayShape="'${SHAPE}'"' \
    -D 'polyhedraDisplayMode="'${MODE}'"' \
    -o $FILENAME \
    polyhedra-tests.scad
}

mkdir -p img
mkdir -p img/tmp
mkdir -p stl

#render_gif "tetrahedron" "wireframe"
#render_gif "octahedron" "wireframe"
#render_gif "hexahedron" "wireframe"
#render_gif "icosahedron" "wireframe"
#render_gif "dodecahedron" "wireframe"

#render_gif "truncated_icosidodecahedron" "wireframe"

ALLSHAPES=("tetrahedron" "octahedron" "hexahedron" "icosahedron" "dodecahedron" "truncated_icosidodecahedron")
for SHAPE in ${ALLSHAPES[@]}
do
   echo $SHAPE
   render_stl $SHAPE "wireframe"
   render_stl $SHAPE "solid"
done

#for SHAPE in "all"; do
#  render_png $SHAPE
#done


##for SHAPE in "all"; do
##  render_stl $SHAPE
##done
