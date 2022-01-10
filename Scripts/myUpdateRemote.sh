#!/bin/sh

for dir in ~/.packages/remote/*; do
	# dirnames are packages, if one isn't installed, don't proceed.
	if pacman -Qq $(basename "$dir") >/dev/null 2>&1; then
		cd "$dir"
		myUpdatePackage.sh
	fi
done
