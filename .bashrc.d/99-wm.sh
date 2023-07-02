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

export _JAVA_OPTIONS='-Dawt.useSystemAAFontSettings=on -Dswing.aatext=true -Dswing.defaultlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel'

if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then
	while [ ! -e /dev/dri/card0 ]
	do
		sleep 0.001
	done
	while [ ! -e /dev/dri/card1 ]
	do
		sleep 0.001
	done

	export WLR_DRM_DEVICES=$(realpath /dev/dri/by-path/pci-0000:28:00.0-card)
	env > /home/simon/out
	exec systemd-cat --identifier=sway sway --unsupported-gpu
fi
#export swaysock for ssh'd headless users.
if [[ -z ${SWAYSOCK} ]]; then
	export SWAYSOCK=$(find /run/user/1000/ -maxdepth 1 -name 'sway-ipc*')
fi
