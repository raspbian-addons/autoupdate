#!/bin/bash

# Core functions
source api
TOKENSCRIPT="/root/token.sh"
if [ ! -f $TOKENSCRIPT ]; then
    error "$TOKENSCRIPT couldn't be found. Exiting."
fi
source $TOKENSCRIPT

status "Updating armcord."
ARMCORD_API=`curl -s --header "Authorization: token $token" https://api.github.com/repos/ArmCord/ArmCord/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")'`
ARMCORD_DATAFILE="$HOME/dlfiles-data/armcord.txt"
if [ ! -f "$ARMCORD_DATAFILE" ]; then
    status "$ARMCORD_DATAFILE does not exist."
    status "Grabbing the latest release from GitHub."
    echo $ARMCORD_API > $ARMCORD_DATAFILE
fi
ARMCORD_CURRENT="$(cat ${ARMCORD_DATAFILE})"
if [ "$ARMCORD_CURRENT" != "$ARMCORD_API" ]; then
    status "armcord isn't up to date. updating now..."
    curl -s --header "Authorization: token $token" https://api.github.com/repos/ArmCord/ArmCord/releases/latest \
      | grep browser_download_url \
      | grep 'arm64.deb"' \
      | cut -d '"' -f 4 \
      | xargs -n 1 curl -L -o armcord_${ARMCORD_API}_arm64.deb || error "Failed to download armcord:arm64"

    mv armcord* $PKGDIR
    echo $ARMCORD_API > $ARMCORD_DATAFILE
    green "armcord" downloaded successfully."
fi
green "armcord is up to date."