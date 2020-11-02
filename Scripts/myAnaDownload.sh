#!/bin/bash
DIR="/$1"
URLDIR=${DIR/\ /%20}
wget "https://uni-bonn.sciebo.de/s/hR8j6ZrjkCFnZyQ/download?path=${URLDIR}&files=" -O .temp
unzip .temp -d "$ana"
rm .temp
