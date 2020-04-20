#!/bin/bash
cd $la
COOKIE=cookie
myCreateCookieECampus.sh "$COOKIE"

function curlLogin() {
    curl "$1" --cookie "$3" -o $2
}

function downloadFilesFromEcampus(){
    curlLogin "$1" temp "$4"
    cat temp | 
        \grep \<h4 | 
        \perl -lpe"s/.*?a href=\"(.*?)\".*?>(.*?)<.*/\$1\n\$2/g" > $3.list
    exCount=$(($(cat $3.list | wc -l)/2))
    for ((i=1;i<=exCount;i++)); do
        urlLine=$(($i*2-1))
        nameLine=$(($urlLine+1))
        url=$(sed "${urlLine}q;d" $3.list)
        name=$(sed "${nameLine}q;d" $3.list)
        curlLogin $url ./$3/$name "$COOKIE"
    done
}
downloadFilesFromEcampus "https://ecampus.uni-bonn.de/goto_ecampus_fold_1663264.html" "\<h4" ex "$COOKIE"
rm cookie ex.list temp
