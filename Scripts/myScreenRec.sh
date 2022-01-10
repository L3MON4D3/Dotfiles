#!/bin/bash

if pgrep -x "wf-recorder" > /dev/null
then
	killall wf-recorder -s SIGINT
	notify-send -t 5000 Finished recording
else
	wf-recorder -g "$(swaymsg -t get_tree | jq -r '.. | (.nodes? // empty)[] | select(.pid and .visible) | .rect | "\(.x),\(.y) \(.width)x\(.height)"' | slurp)" --file=$(date "+%s").mp4
fi
