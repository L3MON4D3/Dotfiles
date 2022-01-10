#!/bin/sh
sed -ri 's/^music_directory ".*"/music_directory "\/mnt\/nfs\/Music"/' /home/simon/.config/mpd/mpd.conf
sed -ri 's/^mpd_music_dir = .*$/mpd_music_dir = \/mnt\/nfs\/Music/' /home/simon/.config/ncmpcpp/config
systemctl --user restart mpd
