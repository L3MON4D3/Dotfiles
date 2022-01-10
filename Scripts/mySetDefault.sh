#!/bin/sh
systemctl --user stop mpd.service
systemctl --user stop $(systemctl --user | grep JACK@ | perl -lpe's/.*(JACK@\d).*/$1/')
systemctl --user start JACK@$1.service
systemctl --user restart pulseaudio.service
systemctl --user start mpd.service
