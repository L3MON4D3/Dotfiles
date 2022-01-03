export _JAVA_AWT_WM_NONREPARENTING=1
export MOZ_ENABLE_WAYLAND=1
export XDG_CURRENT_DESKTOP=sway
export XDG_SESSION_TYPE=wayland

#export __EGL_VENDOR_LIBRARY_FILENAMES=/usr/share/glvnd/egl_vendor.d/50_mesa.json
export QT_QPA_PLATFORM=xcb
export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
export WLR_NO_HARDWARE_CURSORS=1

if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then
	exec systemd-cat --identifier=sway sway --unsupported-gpu
fi
#export swaysock for ssh'd headless users.
if [[ -z ${SWAYSOCK} ]]; then
	export SWAYSOCK=$(find /run/user/1000/ -maxdepth 1 -name 'sway-ipc*')
fi
