#!/bin/bash

# Core functions
source api
TOKENSCRIPT="/root/token.sh"
if [ ! -f $TOKENSCRIPT ]; then
    error "$TOKENSCRIPT couldn't be found. Exiting."
fi
source $TOKENSCRIPT

status "Updating rpi-imager."
RPIIMAGER_API=`curl -s --header "Authorization: token $token" https://api.github.com/repos/raspberrypi/rpi-imager/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")' | tr -d 'v'`
RPIIMAGER_DATAFILE="$HOME/dlfiles-data/rpi-imager.txt"
if [ ! -f "$RPIIMAGER_DATAFILE" ]; then
    status "$RPIIMAGER_DATAFILE does not exist."
    status "Grabbing the latest release from GitHub."
    echo $RPIIMAGER_API > $RPIIMAGER_DATAFILE
fi
RPIIMAGER_CURRENT="$(cat ${RPIIMAGER_DATAFILE})"
if [ "$RPIIMAGER_CURRENT" != "$RPIIMAGER_API" ]; then
    status "rpi-imager isn't up to date. updating now..."
    wget http://archive.raspberrypi.org/debian/pool/main/r/rpi-imager/rpi-imager-dbgsym_${RPIIMAGER_API}_arm64.deb || error "Failed to download rpi-imager-dbgsym:arm64!"
    wget http://archive.raspberrypi.org/debian/pool/main/r/rpi-imager/rpi-imager-dbgsym_${RPIIMAGER_API}_armhf.deb || error "Failed to download rpi-imager-dbgsym:armhf!"
    wget http://archive.raspberrypi.org/debian/pool/main/r/rpi-imager/rpi-imager_${RPIIMAGER_API}_arm64.deb || error "Failed to download rpi-imager:arm64!"
    wget http://archive.raspberrypi.org/debian/pool/main/r/rpi-imager/rpi-imager_${RPIIMAGER_API}_armhf.deb || error "Failed to download rpi-imager:armhf!"
    mv rpi-imager* $PKGDIR
    echo $RPIIMAGER_API > $RPIIMAGER_DATAFILE
    green "rpi-imager downloaded successfully."
fi
green "rpi-imager is up to date."
