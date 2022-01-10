#!/bin/sh
source $HOME/.keychain/${HOSTNAME}-sh
rsync -aAXvRPr $1 --files-from=/home/simon/.sync/restore --exclude-from=/home/simon/.sync/exclude pi@pi:/mnt/external/Backup/Files/home/./ /home/simon/
