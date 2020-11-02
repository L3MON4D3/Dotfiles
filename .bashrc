#
# ~/.bashrc
#

stty start undef
stty -ixon

export PATH=~/Scripts:$PATH:/opt/gradle/gradle-6.0.1/bin
export PIADDR=192.168.2.9
export PIPORT=22
export alpr=~/Documents/Uni/Kurse/s1/AlPro
export luds=~/Documents/Uni/Kurse/s1/LUDS
export ti=~/Documents/Uni/Kurse/s1/TI 

export oose=~/Documents/Uni/Kurse/s2/OoSE
export tdwa=~/Documents/Uni/Kurse/s2/TdwA
export ana=~/Documents/Uni/Kurse/s2/Ana
export la=~/Documents/Uni/Kurse/s2/LA
export si=~/Documents/Uni/Kurse/s2/SI

export num=~/Documents/Uni/Kurse/s3/Num
export swt=~/Documents/Uni/Kurse/s3/Swt
export algo=~/Documents/Uni/Kurse/s3/Algo
export datinf=~/Documents/Uni/Kurse/s3/DatInf
export sys=~/Documents/Uni/Kurse/s3/SysProg

export s3=~/Documents/Uni/Kurse/s3/online

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

source /home/simon/.functions
source /home/simon/.bash_aliases
source /home/simon/.bashrc_local

#dynamically load completions
_completion_loader() {
     . "/usr/share/bash-completion/completions/$1" >/dev/null 2>&1 && return 124
}
complete -D -F _completion_loader -o bashdefault -o default

export PS1="\[\033[0m\][\[\e[38;05;6m\]\W\[\033[0m\]]\[\e[38;05;14m\]\$ \[\033[0m\]"
if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then
	exec sway
fi
