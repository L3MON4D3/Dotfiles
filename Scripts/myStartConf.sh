#!/bin/bash
LINEPRE="$1\."
swaymsg exec "firefox $(grep $LINEPRE /home/simon/Documents/Uni/Kurse/s5/.online | cut -d ';' -f 2)"
