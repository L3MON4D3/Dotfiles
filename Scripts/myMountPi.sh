#!/bin/sh
mount -t 192.168.2.110:/srv/nfs /mnt/nfs
myMusicDirRemote.sh
systemctl --user restart mpd
