#!/bin/bash
mon="$1"   
rep="$1"
if [ "$mon" = "hdmi" ]; then
    mon="HDMI-A-1"
    rep="HDMI-A-1"
fi
if [ $mon = "dvi" ]; then
    mon="DVI-D-1"
    rep="DVI-D-1"
fi
if [ "$mon" = "lp" ]; then
    mon="\*"
    rep="*"
fi
pic=$(echo "$2" | perl -lpe's/\//\\\//g')
echo $pic
sed -ri 's/output '$mon' bg .*/output '$rep' bg '$pic' fill/' /home/simon/.config/sway/config
sway reload
