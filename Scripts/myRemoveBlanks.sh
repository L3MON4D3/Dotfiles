#!/bin/sh
IN="$1"
filename=$(basename "${IN}")
filename="${filename%.*}"
PAGES=$(pdfinfo "$IN" | grep ^Pages: | tr -dc '0-9')

non_blank() {
    for i in $(seq 1 $PAGES)
    do
        PERCENT=$(gs -o -  -dFirstPage=${i} -dLastPage=${i} -sDEVICE=inkcov "$IN" | grep CMYK | nawk 'BEGIN { sum=0; } {sum += $1 + $2 + $3 + $4;} END { printf "%.5f\n", sum } ')
        if [ $(echo "$PERCENT > 0.001" | bc) -eq 1 ]
        then
            echo $i
            #echo $i 1>&2
        fi
        echo -n . 1>&2
    done | tee "$filename.tmp"
    echo 1>&2
}

set +x
pdftk "${IN}" cat $(non_blank) output "${filename}_nb.pdf"
