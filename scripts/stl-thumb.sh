#!/bin/bash

# Core functions
source api
TOKENSCRIPT="/root/token.sh"
if [ ! -f $TOKENSCRIPT ]; then
    error "$TOKENSCRIPT couldn't be found. Exiting."
fi
source $TOKENSCRIPT

status "Updating stl-thumb."
STLTHUMB_API=`curl -s --header "Authorization: token $token" https://api.github.com/repos/unlimitedbacon/stl-thumb/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")'`
STLTHUMB_DATAFILE="$HOME/dlfiles-data/stl-thumb.txt"
if [ ! -f "$STLTHUMB_DATAFILE" ]; then
    status "$STLTHUMB_DATAFILE does not exist."
    status "Grabbing the latest release from GitHub."
    echo $STLTHUMB_API > $STLTHUMB_DATAFILE
fi
STLTHUMB_CURRENT="$(cat ${STLTHUMB_DATAFILE})"
if [ "$STLTHUMB_CURRENT" != "$STLTHUMB_API" ]; then
    status "stl-thumb isn't up to date. updating now..."
    curl -s --header "Authorization: token $token" https://api.github.com/repos/unlimitedbacon/stl-thumb/releases/latest \
      | grep browser_download_url \
      | grep 'arm64.deb"' \
      | cut -d '"' -f 4 \
      | xargs -n 1 curl -L -o stl-thumb_${STLTHUMB_API}_arm64.deb || error "Failed to download stl-thumb:arm64!"

    curl -s --header "Authorization: token $token" https://api.github.com/repos/unlimitedbacon/stl-thumb/releases/latest \
      | grep browser_download_url \
      | grep 'armhf.deb"' \
      | cut -d '"' -f 4 \
      | xargs -n 1 curl -L -o stl-thumb_${STLTHUMB_API}_armhf.deb || error "Failed to download stl-thumb:armhf!"

    mv stl-thumb* $PKGDIR
    echo $STLTHUMB_API > $STLTHUMB_DATAFILE
    green "stl-thumb downloaded successfully."
fi
green "stl-thumb is up to date."
