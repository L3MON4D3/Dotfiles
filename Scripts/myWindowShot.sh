grim -g "$(swaymsg -t get_tree | jq -r '.. | (.nodes? // empty)[] | select(.pid and .visible) | .rect | "\(.x+2),\(.y+2) \(.width-4)x\(.height-4)"' | slurp)" screen.png
