stty start undef
stty -ixon

export PATH=~/.cargo/bin/:~/.local/bin/:~/Scripts:/usr/bin/ccache/bin/:$PATH
export online=~/Documents/Uni/Kurse/s5/.online
export p1=~/Documents/Uni/Kurse/s5/PhysikI
export it=~/Documents/Uni/Kurse/s5/ITSec
export ks=~/Documents/Uni/Kurse/s5/KivS
export pg=~/Documents/Uni/Kurse/s5/PG
export lsn=~/Code/Lua/luasnip
export nc=~/.config/nvim/
export np=~/.local/share/nvim/site/pack/packer/start/

export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'
export LS_COLORS=$LS_COLORS:'ow=01;34:'
export HISTSIZE=-1
export HISTFILESIZE=-1
export HISTCONTROL=ignoredups
export _JAVA_AWT_WM_NONREPARENTING=1
export SUDO_EDITOR=nvim
export MOZ_ENABLE_WAYLAND=1
export XDG_CURRENT_DESKTOP=sway
export XDG_SESSION_TYPE=wayland
export MANPAGER='nvim +Man!'
export SYSTEMD_EDITOR=nvim
export RUST_SRC_PATH=/home/simon/.rustup/toolchains/stable-x86_64-unknown-linux-gnu/lib/rustlib/src/rust/library/

export BAT_THEME="mine"

#export __EGL_VENDOR_LIBRARY_FILENAMES=/usr/share/glvnd/egl_vendor.d/50_mesa.json
export QT_QPA_PLATFORM=xcb
export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
export WLR_NO_HARDWARE_CURSORS=1
export BLOCK_SIZE=4096

export CXX=clang++
export CC=clang
export INCLUDE=/usr/include/stb/
export CMAKE_TOOLCHAIN_FILE=/home/simon/.local/share/mold.cmake

export EDITOR=nvim

export SUDO_ASKPASS=/home/simon/Scripts/myAskPass.sh

source /home/simon/.functions
source /home/simon/.bash_aliases

shopt -s direxpand

##dynamically load completions
#_completion_loader() {
#     . "/usr/share/bash-completion/completions/$1" >/dev/null 2>&1 && return 124
#}
complete -D -F _completion_loader -o bashdefault -o default
source /home/simon/Scripts/complete/*

export PS1="\[\033[0m\][\[\e[38;05;6m\]\W\[\033[0m\]]\[\e[38;05;14m\]\$ \[\033[0m\]"
source /home/simon/.bashrc_local
if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then
	exec systemd-cat --identifier=sway sway --unsupported-gpu
	systemctl --user import-environment SWAYSOCK
fi
#export swaysock for ssh'd headless users.
if [[ -z ${SWAYSOCK} ]]; then
	export SWAYSOCK=$(find /run/user/1000/ -maxdepth 1 -name 'sway-ipc*')
fi
