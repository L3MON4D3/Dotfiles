#!/bin/bash
mon="$1"   
if [ "$mon" = "hdmi" ]; then
    mon="HDMI-A-1"
    picmod='Small'
fi
if [ $mon = "dvi" ]; then
    mon="DVI-D-1"
    picmod='Small'
fi
if [ $mon = "dp" ]; then
    mon="DP-3"
    picmod=''
fi
val=$2
sed -ri 's/output '$mon' transform (0|90|270|180)/output '$mon' transform '$val'/'\
    /home/simon/.config/sway/config
if [ $(($val % 180)) = 90 ]; then
    sed -ri 's/output '$mon' bg .*/output '$mon' bg \/home\/simon\/Pictures\/CurrentWP\/tuxVer'$picmod'.png fill/'\
        /home/simon/.config/sway/config
    if [ "$1" = "dp" ]; then
        sed -ri 's/position (1440|2560),200/position 1440,200/'\
            /home/simon/.config/sway/config
    fi
else
    sed -ri 's/output '$mon' bg .*/output '$mon' bg \/home\/simon\/Pictures\/CurrentWP\/tuxHor'$picmod'.png fill/'\
        /home/simon/.config/sway/config
    if [ "$1" = "dp" ]; then
        sed -ri 's/position (1440|2560),200/position 2560,200/'\
            /home/simon/.config/sway/config
    fi
fi
sway reload
