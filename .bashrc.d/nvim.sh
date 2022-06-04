export nc=~/.config/nvim/
export np=~/.local/share/nvim/site/pack/packer/start/

if [[ -z "${EDITOR}" ]]; then
	export EDITOR=nvim
fi
export SUDO_EDITOR=nvim
export SYSTEMD_EDITOR=nvim
export MANPAGER='nvim +Man!'

alias n='nvim'
alias vim='nvim'
alias :e='nvim'
