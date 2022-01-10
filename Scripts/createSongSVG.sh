#!/bin/bash
songnameSedRdy=$(echo $1 | sed 's/&/\\\&/g')
songname=$1
fColor=$2
echo "$@, $songname"
sed 's/songname/'"$songnameSedRdy"'/;s/inFileName/'"$songnameSedRdy"'/;s/fColor/'"$fColor"'/' ~/.config/albumSVG/generic.gpi > "$songname.gpi"
gnuplot "$songname.gpi"
rm "$songname".dat
rm "$songname".gpi
