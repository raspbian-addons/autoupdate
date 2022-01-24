#!/bin/bash

# Core functions
source api
TOKENSCRIPT="/root/token.sh"
if [ ! -f $TOKENSCRIPT ]; then
    error "$TOKENSCRIPT couldn't be found. Exiting."
fi
source $TOKENSCRIPT

status "Updating starship."
STARSHIP_API=`curl -s --header "Authorization: token $token" https://api.github.com/repos/starship/starship/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")'`
STARSHIP_DATAFILE="$HOME/dlfiles-data/starship.txt"
if [ ! -f "$STARSHIP_DATAFILE" ]; then
    status "$STARSHIP_DATAFILE does not exist."
    status "Grabbing the latest release from GitHub."
    echo $STARSHIP_API > $STARSHIP_DATAFILE
fi
STARSHIP_CURRENT="$(cat ${STARSHIP_DATAFILE})"
if [ "$STARSHIP_CURRENT" != "$STARSHIP_API" ]; then
    status "starship isn't up to date. updating now..."
    STARSHIP_API_NOV=`curl -s --header "Authorization: token $token" https://api.github.com/repos/starship/starship/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")' | tr -d 'v'`
    wget https://github.com/ryanfortner/starship-arm/raw/master/starship_${STARSHIP_API_NOV}_arm64.deb || error "Failed to download starship:arm64"
    wget https://github.com/ryanfortner/starship-arm/raw/master/starship_${STARSHIP_API_NOV}_armhf.deb || error "Failed to download starship:armhf"
    mv starship* $PKGDIR
    echo $STARSHIP_API > $STARSHIP_DATAFILE
    green "starship downloaded successfully."
fi
green "starship is up to date."
