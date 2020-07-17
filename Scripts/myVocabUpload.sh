#!/usr/bin/bash

while IFS=$'\t' read -r -a myArray
do
    GER=${myArray[0]}
    EN=${myArray[1]}
    #echo "$GER":"$EN"
    curl https://api.voc5.org/voc -H 'email:l3mon@4d3.org' -H 'password:foo'\
        --data '{"answer":"'"$EN"'","question":"'"$GER"'","language":"EN"}'
done < $1

