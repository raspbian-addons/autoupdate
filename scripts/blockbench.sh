#!/bin/bash

# Core functions
source api
TOKENSCRIPT="/root/token.sh"
if [ ! -f $TOKENSCRIPT ]; then
    error "$TOKENSCRIPT couldn't be found. Exiting."
fi
source $TOKENSCRIPT

status "Updating blockbench."
BLOCKBENCH_API=`curl -s --header "Authorization: token $token" https://api.github.com/repos/JannisX11/blockbench/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")'`
BLOCKBENCH_DATAFILE="$HOME/dlfiles-data/blockbench.txt"
if [ ! -f "$BLOCKBENCH_DATAFILE" ]; then
    status "$BLOCKBENCH_DATAFILE does not exist."
    status "Grabbing the latest release from GitHub."
    echo $BLOCKBENCH_API > $BLOCKBENCH_DATAFILE
fi
BLOCKBENCH_CURRENT="$(cat ${BLOCKBENCH_DATAFILE})"
if [ "$BLOCKBENCH_CURRENT" != "$BLOCKBENCH_API" ]; then
    status "blockbench isn't up to date. updating now..."
    BLOCKBENCH_API_NOV=`curl -s --header "Authorization: token $token" https://api.github.com/repos/JannisX11/blockbench/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")' | tr -d 'v'`
    wget https://github.com/ryanfortner/blockbench-arm/raw/master/blockbench_${BLOCKBENCH_API_NOV}_arm64.deb || error "Failed to download blockbench:arm64"
    wget https://github.com/ryanfortner/blockbench-arm/raw/master/blockbench_${BLOCKBENCH_API_NOV}_armhf.deb || error "Failed to download blockbench:armhf"
    mv blockbench* $PKGDIR
    echo $BLOCKBENCH_API > $BLOCKBENCH_DATAFILE
    green "blockbench downloaded successfully."
fi
green "blockbench is up to date."
