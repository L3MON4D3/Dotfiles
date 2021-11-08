#!/bin/sh
read lcd < /tmp/lcd"$1"
    if [ "$lcd" -eq "0" ]; then
        swaymsg "output "$1" dpms on"
        echo 1 > /tmp/lcd"$1"
    else
        swaymsg "output "$1" dpms off"
        echo 0 > /tmp/lcd"$1"
    fi
