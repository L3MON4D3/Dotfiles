#!/bin/bash
albumname="$(exiftool "$1"/"$(ls "$1" | sed -n '1p')" | grep Album | perl -lpe 's/Album *: (.*)$/$1/')-album"
bColor=$2
fColor=$3
tColor=$4
mkdir "$albumname"
cd "$albumname"
echo "<svg height=\"1920\" width=\"1080\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" xmlns=\"http://www.w3.org/2000/svg\">" > "$albumname".svg
echo "  <rect height=\"1920\" width=\"1080\" style=\"fill: "$bColor"\"/>" >> "$albumname".svg
crtY=20
for filename in "$1"/*; do
    if [[ $filename =~ ^.*\.(mp3|flac|wav)$ ]]
    then
        songname=$(exiftool "$filename" | grep Title | perl -lpe's/Title *: (.*)$/$1/')
        sox "$filename" "$songname".dat
        createSongSVG.sh "$songname" "$fColor"
        echo "    <text x=\"540\" y=\"$crtY\" style=\"fill: "$tColor";\" text-anchor=\"middle\" textLength=\"1000\">$songname</text>" >> "$albumname".svg
        echo "    <image x=\"0\" y=\"$((crtY+10))\" width=\"1080\" height=\"70\" xlink:href=\""$songname".svg\"/>" >> "$albumname".svg
        crtY=$((crtY+=120))
    fi
done
echo "</svg>" >> "$albumname".svg
sed 's/\&/\&amp\;/g' "$albumname".svg > "$albumname"2.svg
mv "$albumname"2.svg "$albumname".svg
