alias swayconf='cd ~/.config/sway; n config'
alias waybarconf='vim ~/.config/waybar/config'
alias winsel='swaymsg -t get_tree | jq -r '\''.. | (.nodes? // empty)[] | select(.pid and .visible) | .rect | "\(.x),\(.y) \(.width)x\(.height)"'\'' | slurp'
alias rotEx='myRotateDisplay.sh'

export _JAVA_AWT_WM_NONREPARENTING=1
export MOZ_ENABLE_WAYLAND=1
export XDG_CURRENT_DESKTOP=sway
export XDG_SESSION_TYPE=wayland
export WLR_NO_HARDWARE_CURSORS=0

export QT_QPA_PLATFORM=wayland
export QT_WAYLAND_DISABLE_WINDOWDECORATION=1

if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then
	exec systemd-cat --identifier=sway sway
fi
#export swaysock for ssh'd headless users.
if [[ -z ${SWAYSOCK} ]]; then
	export SWAYSOCK=$(find /run/user/1000/ -maxdepth 1 -name 'sway-ipc*')
fi
