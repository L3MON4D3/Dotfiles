#
# ~/.bashrc
#

stty start undef
stty -ixon

export PATH=~/Scripts:$PATH:/opt/gradle/gradle-6.0.1/bin
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk
export PIADDR=192.168.2.119
export luds=~/Documents/Uni/Kurse/LUDS
export alpr=~/Documents/Uni/Kurse/AlPro
export ti=~/Documents/Uni/Kurse/TI 
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'
export LS_COLORS=$LS_COLORS:'ow=01;34:'

source /home/simon/.functions
source /home/simon/.bash_aliases

PS1='[\u@\h \W]\$ '
if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then
	exec sway
fi
