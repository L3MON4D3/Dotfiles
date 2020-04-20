#!/bin/bash
DIR="/$1"
URLDIR=${DIR/\//%2F}
URLDIR=${DIR/\ /%20}
echo "https://uni-bonn.sciebo.de/s/hR8j6ZrjkCFnZyQ/download?path=${URLDIR}&files=" 
wget "https://uni-bonn.sciebo.de/s/hR8j6ZrjkCFnZyQ/download?path=${URLDIR}&files=" -O .temp
unzip .temp -d "$ana"
