#
# ~/.bashrc
#

stty start undef
stty -ixon

export PATH=~/Scripts:$PATH:/opt/gradle/gradle-6.0.1/bin
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk
export PIADDR=192.168.2.9
export alpr=~/Documents/Uni/Kurse/s1/AlPro
export ana=~/Documents/Uni/Kurse/s2/Ana
export la=~/Documents/Uni/Kurse/s2/LA
export luds=~/Documents/Uni/Kurse/s1/LUDS
export oose=~/Documents/Uni/Kurse/s2/OoSE
export tdwa=~/Documents/Uni/Kurse/s2/TdwA
export ti=~/Documents/Uni/Kurse/s1/TI 
export si=~/Documents/Uni/Kurse/s2/SI
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'
export LS_COLORS=$LS_COLORS:'ow=01;34:'
export HISTSIZE=-1
export HISTFILESIZE=-1
export HISTCONTROL=ignoredups
export _JAVA_AWT_WM_NONREPARENTING=1


source /home/simon/.functions
source /home/simon/.bash_aliases

#dynamically load completions
_completion_loader() {
     . "/usr/share/bash-completion/completions/$1" >/dev/null 2>&1 && return 124
}
complete -D -F _completion_loader -o bashdefault -o default


PS1="\[\033[0m\][\e[38;05;6m\W\[\033[0m\]]\e[38;05;14m\$ \[\033[0m\]"
if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then
	exec sway
fi
