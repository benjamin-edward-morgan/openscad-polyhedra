#!/bin/bash -e

function check_openscad() {
  openscad -v >/dev/null 2>&1 || {
    printf "Please set up OpenSCAD so that it can be used in this script.\nSee https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Using_OpenSCAD_in_a_command_line_environment\n"
    exit 1
  }
}

function check_magick() {
  magick -version >/dev/null 2>&1 || {
    printf "Please set up ImageMagick. You should be able to do this from your favorite package manager like Homebrew or apt-get."
    exit 1
  }
}

function print_usage() {
  echo "Usage: [shape] [mode] [type]"
  echo "- shape can be \"tetrahedron\", \"octahedron\" etc, \"layout\" or \"all\""
  echo "- mode can be \"enumerated\", \"wireframe\" or \"solid\""
  echo "- type can be \"stl\", \"png\" or \"gif\""
  exit 0
}

function render_png() {
  check_openscad
  check_magick
  SHAPE=$1
  MODE=$2
  mkdir -p img
  FILENAMEX4="img/${SHAPE}_${MODE}_x4.png"
  FILENAME="img/${SHAPE}_${MODE}.png"
  echo -e "rendering ${FILENAME}"
  openscad \
    --camera=-0,0,0,55,0,25,160 \
    --imgsize=8192,6144 \
    --projection=p \
    --colorscheme="Tomorrow Night" \
    -D 'polyhedraDisplayShape="'${SHAPE}'"' \
    -D 'polyhedraDisplayMode="'${MODE}'"' \
    -D "polyhedraNoScale=false" \
    -o ${FILENAMEX4} \
    polyhedra-tests.scad
  magick ${FILENAMEX4} -resize 2048x1536 ${FILENAME}
  rm ${FILENAMEX4}


}

function render_gif() {
  check_openscad
  check_magick
  SHAPE=$1
  MODE=$2
  mkdir -p img
  mkdir -p img/tmp
  rm -f img/tmp/*
  for i in `seq 0 5 359`
  do
    PADDED=$(printf "%03d" $i)
    FILENAME="img/tmp/${SHAPE}_${MODE}_${PADDED}.png"
    echo -e "rendering ${FILENAME}"
    openscad \
      --camera=-0,0,0,55,0,$i,140 \
      --imgsize=256,192 \
      --projection=p \
      --colorscheme="Tomorrow Night" \
      -D 'polyhedraDisplayShape="'${SHAPE}'"' \
      -D 'polyhedraDisplayMode="'${MODE}'"' \
      -D "polyhedraNoScale=false" \
      -o $FILENAME \
      polyhedra-tests.scad
  done

  magick img/tmp/*.png img/${SHAPE}_${MODE}.gif

  rm -fr img/tmp
}

function render_stl() {
  check_openscad
  SHAPE=$1
  MODE=$2
  mkdir -p stl
  FILENAME="stl/${SHAPE}_${MODE}.stl"
  echo -e "rendering ${FILENAME}"
  openscad \
    -D 'polyhedraDisplayShape="'${SHAPE}'"' \
    -D 'polyhedraDisplayMode="'${MODE}'"' \
    -D "polyhedraNoScale=false" \
    -o $FILENAME \
    polyhedra-tests.scad
}

function build_type() {
  SHAPE=$1
  MODE=$2
  TYPE=$3
  case "$TYPE" in
    "png" )
      render_png $SHAPE $MODE ;;
    "gif" )
      render_gif $SHAPE $MODE ;;
    "stl" )
      render_stl $SHAPE $MODE ;;
    *     )
      echo "Unknown type $TYPE"
      print_usage
  esac
}

ALLSHAPES=("tetrahedron" "octahedron" "hexahedron" "icosahedron" "dodecahedron" "truncated_icosidodecahedron" "cubeoctahedron" "truncated_tetrahedron" "snub_cube" "rhombicuboctahedron" "truncated_hexahedron" "truncated_octahedron" "icosidodecahedron" "snub_dodecahedron" "rhombicosidodecahedron" "truncated_cuboctahedron" "truncated_icosahedron" "truncated_dodecahedron" "truncated_icosidodecahedron")

if [ $# -ne "3" ]
then
  print_usage
else
  SHAPE=$1
  MODE=$2
  TYPE=$3

  if [ "$SHAPE" == "all" ]
  then
     for SH in ${ALLSHAPES[@]}
     do
       build_type $SH $MODE $TYPE
     done
  else
    build_type $SHAPE $MODE $TYPE
  fi

fi
