# prio 30: override pacman-p-alias.

alias p=paru

source /usr/share/bash-completion/completions/paru.bash
complete -F _paru p

function p() {
	paru $@
	# update own packages only if called without args.
	if [[ $# -eq 0 ]]; then
		# not bad if this doesn't exist.
		myUpdateRemote.sh
	fi
}
