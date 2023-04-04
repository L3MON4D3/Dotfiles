#!/bin/bash

tmpdir="/tmp/$(mktemp -u XXXXXXXX)"
mkdir "$tmpdir"

tmp="$tmpdir"/$(basename "$1")

if [[ -f "$1" ]]
then
	sudo cat "$1" > "$tmp"
else
	# just get sudo
	sudo true
fi

inotifywait -m "$tmp" -e create -e modify 2> /dev/null > \
    >(sudo sh -c "while read path action file; do cp '$tmp' '$1'; done") &

pid=$!

sh -c "$EDITOR $tmp"
kill $pid
rm "$tmp"
