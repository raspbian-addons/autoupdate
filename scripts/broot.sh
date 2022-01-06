#!/bin/bash

# Core functions
source api
TOKENSCRIPT="/root/token.sh"
if [ ! -f $TOKENSCRIPT ]; then
    error "$TOKENSCRIPT couldn't be found. Exiting."
fi
source $TOKENSCRIPT

status "Updating broot."
BROOT_API=`curl -s --header "Authorization: token $token" https://api.github.com/repos/Canop/broot/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")' | tr -d 'v'`
BROOT_DATAFILE="$HOME/dlfiles-data/broot.txt"
if [ ! -f "$BROOT_DATAFILE" ]; then
    status "$BROOT_DATAFILE does not exist."
    status "Grabbing the latest release from GitHub."
    echo $BROOT_API > $BROOT_DATAFILE
fi
BROOT_CURRENT="$(cat ${BROOT_DATAFILE})"
if [ "$BROOT_CURRENT" != "$BROOT_API" ]; then
    status "broot isn't up to date. updating now..."
    wget https://github.com/ryanfortner/broot-arm/raw/master/broot_${BROOT_API}_armhf.deb -O broot_${BROOT_API}_armhf.deb || error "Failed to download broot:armhf!"
    mv broot* $PKGDIR
    echo $BROOT_API > $BROOT_DATAFILE
    green "broot downloaded successfully."
fi
green "broot is up to date."
