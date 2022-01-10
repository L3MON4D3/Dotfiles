#!/bin/bash

tmpdir="/tmp/$(mktemp -u XXXXXXXX)"
mkdir "$tmpdir"

tmp="$tmpdir"/$(basename "$1")

sudo cat "$1" > "$tmp"
inotifywait -m "$tmp" -e create -e modify 2> /dev/null > \
    >(sudo sh -c "while read path action file; do cp '$tmp' '$1'; done") &

pid=$!

sh -c "$EDITOR $tmp"
kill $pid
rm "$tmp"
