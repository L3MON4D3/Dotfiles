#!/bin/bash

FILE=$(mktemp -u /tmp/popout_XXXX)
SLURP=$(slurp)
grim -g "$SLURP" "$FILE"

X=$(echo $SLURP | perl -lpe 's/(\d+),\d+.*/$1/g')
Y=$(echo $SLURP | perl -lpe 's/\d+,(\d+).*/$1/g')
echo $X $Y

WIDTH=$(identify "$FILE" | perl -lpe 's/.* (\d+)x\d+ .*/$1/g')
HEIGHT=$(identify "$FILE" | perl -lpe 's/.* \d+x(\d+) .*/$1/g')

swaymsg 'for_window [title="^imv .*'$FILE'.*"] "floating enable, resize set '$WIDTH' '$HEIGHT',move absolute position '$X' '$Y'"'

imv "$FILE"
