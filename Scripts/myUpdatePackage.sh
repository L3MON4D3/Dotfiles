#!/bin/sh

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

# Run makepkg in current dir, add package to repo if a new one was built.
# $1 will passed to pacman (eg. --dbonly for packages built from
# local files).

# create new fifo, store to cleanup later.
pname=$(mktemp -u)
mkfifo "$pname"

# create file to store output, makepkg prints lots of undesired text
# if the package is up-to-date, so stdout is only shown if a new version
# was built.
p2name=$(mktemp)

# -d: ignore missing dependencies.
# append output to temporary named pipe for async processing, to file for
# printing stdout (>/dev/null to not clutter output with failed builds).
# unbuffer for colors in output, remove later using ansi-codes.
# log all output to view with journalctl, may be useful.
unbuffer makepkg -d 2>&1 | tee "$pname" "$p2name" | ansifilter | systemd-cat -t myUpdatePackage.sh &

packagename=$(grep "Finished making" "$pname" | \
	# ansifilter to remove ansi-codes, perl needs plain text.
	ansifilter | \
	# $1 is package-name, $2 is version.
	perl -lpe 's/==> Finished making: ([^ ]+) ([^ ]+).*/$1-$2*.zst/g')

if [ ! -z "$packagename" ]; then
	# show stdout from makepkg.
	cat "$p2name"
	file=$(compgen -G "$packagename")
	# add generated file to repo.
	dbpush "$file"
	sudo pacman -U --noconfirm $1 "$file"
else
	echo -e "\033[;1m\033[32m==>\033[97m $(basename $(pwd)) is up to date"
fi

rm -f "$pname"
rm -f "$p2name"
