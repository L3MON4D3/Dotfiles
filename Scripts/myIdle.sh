#!/bin/bash

if [[ $(mpc status | grep -o playing) == "" ]]; then
	sudo systemctl suspend
fi
