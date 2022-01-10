#!/bin/sh
source $HOME/.keychain/${HOSTNAME}-sh
rsync -aAXvRPr $1\
	--files-from=/home/simon/.sync/backup\
	--exclude-from=/home/simon/.sync/exclude\
	/home/simon/ pi@pi:/mnt/external/Backup/Files/home

rsync -aAXvRPr $1\
	--files-from=/home/simon/.sync/backup_local\
	--exclude-from=/home/simon/.sync/exclude_local\
	/ pi@pi:/mnt/external/Backup/$(hostname)_Files

#Save package-list.
paru -Qqet | ssh pi@pi "cat > /mnt/external/Backup/$(hostname)_pkg"

for dir in ~/.packages/local/*; do
	# dirnames are packages, if one isn't installed, don't proceed.
	if pacman -Qq $(basename "$dir") >/dev/null 2>&1; then
		cd "$dir"
		myUpdatePackage.sh --dbonly
	fi
done
