#!/bin/bash
ALL_COLORS=('#fb4934' '#b8bb26' '#fabd2f' '#458588' '#b16286' '#8ec07c' '#f38019')
declare -a MIX_COLORS
ARR_SZ=${#ALL_COLORS[@]}

#Durstenfeld-Shuffle
for (( i=0; i != $ARR_SZ; i++)); do
    LAST_i=$(( $ARR_SZ-$i ))
    NUM=$(( RANDOM % $LAST_i ))

    MIX_COLORS[$i]=${ALL_COLORS[$NUM]}
    ALL_COLORS[$NUM]=${ALL_COLORS[(( $LAST_i-1 ))]}
done

myTuxVerGen.sh "${MIX_COLORS[1]}" "${MIX_COLORS[2]}" "${MIX_COLORS[3]}" tuxBigV.svg
myTuxHorGen.sh "${MIX_COLORS[1]}" "${MIX_COLORS[2]}" "${MIX_COLORS[3]}" tuxBigH.svg

myTuxVerGen.sh "${MIX_COLORS[4]}" "${MIX_COLORS[5]}" "${MIX_COLORS[6]}" tuxSmallV.svg
myTuxHorGen.sh "${MIX_COLORS[4]}" "${MIX_COLORS[5]}" "${MIX_COLORS[6]}" tuxSmallH.svg

echo ${MIX_COLORS[@]}
echo ${ALL_COLORS[@]}

#Redirect output to file as not to clutter console
pid1=$(inkscape --export-type="png" --export-filename="tuxVerSmall.png" -w 1080 -h 1920 tuxSmallV.svg > out & echo $!)
pid2=$(inkscape --export-type="png" --export-filename="tuxVer.png" -w 1440 -h 2560 tuxBigV.svg > out & echo $!)
pid3=$(inkscape --export-type="png" --export-filename="tuxHorSmall.png" -w 1920 -h 1080 tuxSmallH.svg > out & echo $!)
pid4=$(inkscape --export-type="png" --export-filename="tuxHor.png" -w 2560 -h 1440 tuxBigH.svg > out & echo $!)

tail --pid=$pid1 -f /dev/null
tail --pid=$pid2 -f /dev/null
tail --pid=$pid3 -f /dev/null
tail --pid=$pid4 -f /dev/null

rm tuxBigV.svg tuxBigH.svg tuxSmallV.svg tuxSmallH.svg out
