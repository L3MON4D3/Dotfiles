#!/bin/bash
cd $la
myECampusDownload.sh "https://ecampus.uni-bonn.de/goto_ecampus_fold_1663264.html"

for i in *.pdf; do
    mkdir $(echo "$i" | perl -lpe's/.*?(\d{2})\.pdf/ex\/$1/g')
done

perl-rename 's/Zettel(\d{2})\.pdf/ex\/$1\/Aufgabe/g' *.pdf
perl-rename 's/Zettel(\d{2})_Musterloesung\.(.*)/ex\/$1\/Loesung\.$2/g' *
