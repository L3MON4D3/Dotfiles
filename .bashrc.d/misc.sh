stty start undef
stty -ixon

export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'
export LS_COLORS=$LS_COLORS:'ow=01;34:'

export HISTSIZE=-1
export HISTFILESIZE=-1
export HISTCONTROL=ignoredups

export BLOCK_SIZE=4096

#export PATH=~/.local/bin/:$PATH

export CXX=clang++
export CC=clang
export INCLUDE=/usr/include/stb/
export CMAKE_TOOLCHAIN_FILE=/home/simon/.local/share/mold.cmake

export PATH=~/.cargo/bin/:~/Scripts:/usr/bin/ccache/bin/:$PATH
export online=~/Documents/Uni/Kurse/s5/.online
export p1=~/Documents/Uni/Kurse/s5/PhysikI
export it=~/Documents/Uni/Kurse/s5/ITSec
export ks=~/Documents/Uni/Kurse/s5/KivS
export pg=~/Documents/Uni/Kurse/s5/PG
export lsn=~/Code/Lua/luasnip

export RUST_SRC_PATH=/home/simon/.rustup/toolchains/stable-x86_64-unknown-linux-gnu/lib/rustlib/src/rust/library/

export SUDO_ASKPASS=/home/simon/Scripts/myAskPass.sh
