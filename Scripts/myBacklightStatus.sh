#!/bin/sh
trap 'printf "%03d%s\n" "$(($(cat /sys/class/backlight/intel_backlight/brightness)/15))"' 10

while true
do
    read
done
