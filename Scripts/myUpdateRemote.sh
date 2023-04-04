#!/bin/sh

for dir in ~/.packages/remote/*; do
	# dirnames are packages, if one isn't installed, don't proceed.
	if pacman -Qq $(basename "$dir") >/dev/null 2>&1; then
		cd "$dir"
		if makepkg -d; then
			package=$(ls -1t | head -n1)
			echo -e "\033[;1m\033[32m==>\033[97m Installing $package"
			sudo pacman --noconfirm -U "$package"
			echo -e "\033[;1m\033[32m==>\033[97m Uploading $package"
			cp "$package" /mnt/repo/x86_64/
			repo-add /mnt/repo/archlinux/l3mon/os/x86_64/l3mon.db.tar "$package"
		fi
	fi
done
