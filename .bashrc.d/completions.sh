shopt -s direxpand

##dynamically load completions
#_completion_loader() {
#     . "/usr/share/bash-completion/completions/$1" >/dev/null 2>&1 && return 124
#}
complete -D -F _completion_loader -o bashdefault -o default
source /home/simon/Scripts/complete/*

