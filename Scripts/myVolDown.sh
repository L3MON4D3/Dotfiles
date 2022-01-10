#!/bin/bash
amixer -c 1 set Master 4%- -M
amixer -c 0 set 'UMC202HD 192k Output' 4%- -M
ssh -t pi@192.168.2.109 "amixer -c 1 set 'UMC202HD 192k Output' 4%- -M"
kill -10 $(pidof -x myVolumeStatus.sh)
