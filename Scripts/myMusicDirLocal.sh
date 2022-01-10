sed -ri 's/^music_directory ".*"$$/music_directory "\/home\/simon\/Music"/' /home/simon/.config/mpd/mpd.conf
sed -ri 's/^mpd_music_dir = .*$/mpd_music_dir = \/home\/simon\/Music/' /home/simon/.config/ncmpcpp/config
systemctl --user restart mpd
