#!/bin/bash

# Core functions
source api
TOKENSCRIPT="/root/token.sh"
if [ ! -f $TOKENSCRIPT ]; then
    error "$TOKENSCRIPT couldn't be found. Exiting."
fi
source $TOKENSCRIPT

status "Updating electron-fiddle."
ELECTRONFIDDLE_API=`curl -s --header "Authorization: token $token" https://api.github.com/repos/electron/fiddle/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")'`
ELECTRONFIDDLE_DATAFILE="$HOME/dlfiles-data/electron-fiddle.txt"
if [ ! -f "$ELECTRONFIDDLE_DATAFILE" ]; then
    status "$ELECTRONFIDDLE_DATAFILE does not exist."
    status "Grabbing the latest release from GitHub."
    echo $ELECTRONFIDDLE_API > $ELECTRONFIDDLE_DATAFILE
fi
ELECTRONFIDDLE_CURRENT="$(cat ${ELECTRONFIDDLE_DATAFILE})"
if [ "$ELECTRONFIDDLE_CURRENT" != "$ELECTRONFIDDLE_API" ]; then
    status "electron-fiddle isn't up to date. updating now..."
    curl -s --header "Authorization: token $token" https://api.github.com/repos/electron/fiddle/releases/latest \
      | grep browser_download_url \
      | grep 'arm64.deb"' \
      | cut -d '"' -f 4 \
      | xargs -n 1 curl -L -o electron-fiddle_${ELECTRONFIDDLE_API}_arm64.deb || error "Failed to download electron-fiddle:arm64!"

    curl -s --header "Authorization: token $token" https://api.github.com/repos/electron/fiddle/releases/latest \
      | grep browser_download_url \
      | grep 'armhf.deb"' \
      | cut -d '"' -f 4 \
      | xargs -n 1 curl -L -o electron-fiddle_${ELECTRONFIDDLE_API}_armhf.deb || error "Failed to download electron-fiddle:armhf!"

    mv electron-fiddle* $PKGDIR
    echo $ELECTRONFIDDLE_API > $ELECTRONFIDDLE_DATAFILE
    green "electron-fiddle downloaded successfully."
fi
green "electron-fiddle is up to date."
