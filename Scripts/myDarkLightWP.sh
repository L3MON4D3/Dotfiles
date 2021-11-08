#!/bin/bash
if [[ $# -eq 2 ]]; then
	TIME=$2
else
	TIME=$(date +"%H%M")
fi
BASE="/home/simon/Pictures/Appearance"
ENDING=

switch() {
	swaymsg output eDP-1 bg $BASE/2560$ENDING fill > /dev/null
	swaymsg output DP-1 bg $BASE/2560$ENDING fill > /dev/null
	swaymsg output HDMI-A-1 bg $BASE/1080$ENDING fill > /dev/null
}

#$TIME >= 1000
#if 1 is supplied as argument, only switch if it is exactly 10:00 or 18:00.
#else switch always (Prevents screen flickering if there isnt actually
#something to swap.)
if [[ "$1" -eq 1 ]]; then
	if [ $TIME -eq "0800" ]; then
		#Apply light theme
		ENDING=".png"
		switch
	else
		if [ $TIME -eq "2100" ]; then
			#Apply dark theme
			ENDING="_dark.png"
			switch
		fi
	fi
else
	if [[ $TIME > 0800 && $TIME < 2100 ]]; then
		#Apply light theme
		ENDING=".png"
	else
		#Apply dark theme
		ENDING="_dark.png"
	fi
	switch
fi
