alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias reboot='sudo systemctl reboot'
alias mount='sudo mount'
alias umount='sudo umount'
alias pacman='sudo pacman'
alias ..='cd ..'
alias l='ls'
alias la='ls -a'
alias ll='ls -l'
alias rmr='rm -rf'
alias c='clear'
alias pud='pushd'
alias pod='popd'
alias curl='curl -w "\n"'
alias gs='git status'
alias gti='git'
alias g='git'
alias pe='perl -lpe'
alias rs='rsync -ah --progress'
alias less='less -r'
alias p-r='perl-rename'
alias ip='ip -c'
alias sus='systemctl suspend'
alias paste="curl -F 'sprunge=<-' http://sprunge.us"
alias ch='cht.sh'

package_name() {
	echo "$1" | perl -lpe 's/^(.*)-[^-]+-[^-]+-[^-.]+\.(.*)$/$1.$2/'
}

dbpush() {
	for package in "$@"
	do
		db_name=$(package_name $(basename -- "$package"))
		cp "$package" "/mnt/repo/archlinux/l3mon/os/x86_64/$db_name" && repo-add /mnt/repo/archlinux/l3mon/os/x86_64/{l3mon.db.tar,"$db_name"}
	done
}

alias p='pacman'

stty start undef
stty -ixon

source ~/.functions

export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'
export LS_COLORS=$LS_COLORS:'ow=01;34:'

export HISTSIZE=-1
export HISTFILESIZE=-1
export HISTCONTROL=ignoredups:erasedups
shopt -s histappend

export BLOCK_SIZE=4096

#export PATH=~/.local/bin/:$PATH

export CXX=clang++
export CC=clang
export INCLUDE=/usr/include/stb/

export PATH=~/.cargo/bin/:~/Scripts:/usr/bin/ccache/bin/:~/.local/bin/:/usr/bin/vendor_perl/:$PATH
shopt -s direxpand
export cg1=~/Documents/Uni/Kurse/s8/cg1/
export ma=~/Documents/Uni/Kurse/s8/ma/
export omp=~/Documents/Uni/Kurse/s8/omp
export lsn=~/Code/luasnip

export RUST_SRC_PATH=/home/simon/.rustup/toolchains/stable-x86_64-unknown-linux-gnu/lib/rustlib/src/rust/library/

export SUDO_ASKPASS=/home/simon/Scripts/myAskPass.sh
