#!/bin/bash
if [ $1 = -u ] 
then
	crtVal=$(( $(sudo cat /sys/class/backlight/intel_backlight/brightness) + $2 ))
	echo $crtVal | sudo tee /sys/class/backlight/intel_backlight/brightness 
elif [ $1 = -d ]
then
	crtVal=$(( $(sudo cat /sys/class/backlight/intel_backlight/brightness) - $2 ))
	echo $crtVal | sudo tee /sys/class/backlight/intel_backlight/brightness
fi
kill -10 $(pidof -x myBacklightStatus.sh )
