#!/bin/bash
LINEPRE="$1\."
swaymsg exec "chromium --ozone-platform-hint=auto $(grep $LINEPRE /home/simon/Documents/Uni/Kurse/s5/.online | cut -d ';' -f 2)"
