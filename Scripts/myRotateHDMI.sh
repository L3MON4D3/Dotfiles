#!/bin/sh
rotVal=$1
sed -ri 's/output HDMI-A-1 resolution 1080x1920 transform (0|90|270|180)/output HDMI-A-1 resolution 1080x1920 transform '$rotVal'/' /home/simon/.config/sway/config
sway reload
