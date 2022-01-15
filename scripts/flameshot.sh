#!/bin/bash

# Core functions
source api
TOKENSCRIPT="/root/token.sh"
if [ ! -f $TOKENSCRIPT ]; then
    error "$TOKENSCRIPT couldn't be found. Exiting."
fi
source $TOKENSCRIPT

status "Updating flameshot."
FLAMESHOT_API=`curl -s --header "Authorization: token $token" https://api.github.com/repos/flameshot-org/flameshot/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")' | tr -d 'v'`
FLAMESHOT_DATAFILE="$HOME/dlfiles-data/flameshot.txt"
if [ ! -f "$FLAMESHOT_DATAFILE" ]; then
    status "$FLAMESHOT_DATAFILE does not exist."
    status "Grabbing the latest release from GitHub."
    echo $FLAMESHOT_API > $FLAMESHOT_DATAFILE
fi
FLAMESHOT_CURRENT="$(cat ${FLAMESHOT_DATAFILE})"
if [ "$FLAMESHOT_CURRENT" != "$FLAMESHOT_API" ]; then
    status "flameshot isn't up to date. updating now..."
    wget https://github.com/flameshot-org/flameshot/releases/download/v${FLAMESHOT_API}/flameshot-${FLAMESHOT_API}-1.debian-10.armhf.deb || error "Failed to download flameshot:armhf"
    wget https://github.com/flameshot-org/flameshot/releases/download/v${FLAMESHOT_API}/flameshot-${FLAMESHOT_API}-1.debian-10.arm64.deb || error "Failed to download flameshot:arm64"
    mv flameshot* $PKGDIR
    echo $FLAMESHOT_API > $FLAMESHOT_DATAFILE
    green "flameshot downloaded successfully."
fi
green "flameshot is up to date."
