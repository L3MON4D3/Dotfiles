#!/bin/bash
for filename in * ; do
    echo "$filename"
    ffmpeg -i "$filename" -c:a copy -x265-params crf=25 "$(echo "$filename" | perl -lpe 's/^(.*)(\.mkv)$/$1_x264.mkv/g')"
done
