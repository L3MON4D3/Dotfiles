#!/bin/bash
pidof waybar && kill $(pidof waybar)
env GTK_THEME=none waybar
