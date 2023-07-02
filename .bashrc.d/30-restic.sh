alias backup='l3mon-resticctl backup manual'
alias lr='l3mon-restic'

[[ $(type -f poweroff 2>/dev/null | rg -o alias) == alias ]] && unalias poweroff
poweroff() {
	read -t 5 -p "Don't Backup? [y/Y] " dont_backup
	[[ ! $dont_backup == [yY] ]] && l3mon-resticctl backup manual
	sudo systemctl poweroff
}
export -f poweroff

[[ $(type -f suspend 2>/dev/null | rg -o alias) == alias ]] && unalias suspend
suspend() {
	read -t 5 -p "Don't Backup? [y/Y] " dont_backup
	[[ ! $dont_backup == [yY] ]] && l3mon-resticctl backup manual
	sudo systemctl suspend
}
export -f suspend
