grim -g "$( {
swaymsg -t get_tree | jq -r '.. | (.nodes? // empty)[] | select(.pid and .visible) | .rect | "\(.x),\(.y) \(.width)x\(.height)"' ;
		swaymsg -t get_tree | jq -r '.. | (.floating_nodes? // empty)[] | select(.pid and .visible) | .rect | "\(.x+1),\(.y) \(.width-2)x\(.height-1)"' ; } | slurp)" screen.png
