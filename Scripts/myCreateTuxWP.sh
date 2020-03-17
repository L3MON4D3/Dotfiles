#!/bin/bash
ALL_COLORS=('#fb4934' '#b8bb26' '#fabd2f' '#458588' '#b16286' '#8ec07c' '#f38019')
declare -a MIX_COLORS
ARR_SZ=${#ALL_COLORS[@]}

#only prepare wallpapers for next restart as creation takes too long and colors
#may appear twice (UNACCEPTABLE!!!)
for (( i=0; i != $(( ARR_SZ )); i++)); do
    NUM=$(( RANDOM % $ARR_SZ ))
    MOD=0
    #Test if color already in use, if it is increase NUM by one until valid
    while [ -z ${ALL_COLORS[$(( NUM + MOD ))]} ]; do
        if [ $(( $NUM+$MOD )) -eq $(( ARR_SZ-1 )) ]; then
            NUM=-1
            MOD=0
        fi
        ((MOD++))
    done
    MIX_COLORS[$i]="${ALL_COLORS[$(( NUM + MOD ))]}"
    ALL_COLORS[$(( NUM+MOD ))]=""
done

myTuxVerGen.sh "${MIX_COLORS[1]}" "${MIX_COLORS[2]}" "${MIX_COLORS[3]}" tuxBigV.svg
myTuxHorGen.sh "${MIX_COLORS[1]}" "${MIX_COLORS[2]}" "${MIX_COLORS[3]}" tuxBigH.svg

myTuxVerGen.sh "${MIX_COLORS[4]}" "${MIX_COLORS[5]}" "${MIX_COLORS[6]}" tuxSmallV.svg
myTuxHorGen.sh "${MIX_COLORS[4]}" "${MIX_COLORS[5]}" "${MIX_COLORS[6]}" tuxSmallH.svg

#Redirect output to file as not to clutter console
inkscape -z -e tuxVerSmall.png -w 1080 -h 1920 tuxSmallV.svg > out
inkscape -z -e tuxVer.png -w 1440 -h 2560 tuxBigV.svg > out

inkscape -z -e tuxHorSmall.png -w 1920 -h 1080 tuxSmallH.svg > out
inkscape -z -e tuxHor.png -w 2560 -h 1440 tuxBigH.svg > out

rm tuxBigV.svg tuxBigH.svg tuxSmallV.svg tuxSmallH.svg out
