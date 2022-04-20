#!/bin/bash

# Core functions
source api
TOKENSCRIPT="/root/token.sh"
if [ ! -f $TOKENSCRIPT ]; then
    error "$TOKENSCRIPT couldn't be found. Exiting."
fi
source $TOKENSCRIPT

status "Updating stl-thumb-kde."
STLTHUMBKDE_API=`curl -s --header "Authorization: token $token" https://api.github.com/repos/unlimitedbacon/stl-thumb-kde/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")'`
STLTHUMBKDE_DATAFILE="$HOME/dlfiles-data/stl-thumb-kde.txt"
if [ ! -f "$STLTHUMBKDE_DATAFILE" ]; then
    status "$STLTHUMBKDE_DATAFILE does not exist."
    status "Grabbing the latest release from GitHub."
    echo $STLTHUMBKDE_API > $STLTHUMBKDE_DATAFILE
fi
STLTHUMBKDE_CURRENT="$(cat ${STLTHUMBKDE_DATAFILE})"
if [ "$STLTHUMBKDE_CURRENT" != "$STLTHUMBKDE_API" ]; then
    status "stl-thumb-kde isn't up to date. updating now..."
    curl -s --header "Authorization: token $token" https://api.github.com/repos/unlimitedbacon/stl-thumb-kde/releases/latest \
      | grep browser_download_url \
      | grep 'arm64.deb"' \
      | cut -d '"' -f 4 \
      | xargs -n 1 curl -L -o stl-thumb-kde_${STLTHUMBKDE_API}_arm64.deb || error "Failed to download stl-thumb-kde:arm64!"

    curl -s --header "Authorization: token $token" https://api.github.com/repos/unlimitedbacon/stl-thumb-kde/releases/latest \
      | grep browser_download_url \
      | grep 'armhf.deb"' \
      | cut -d '"' -f 4 \
      | xargs -n 1 curl -L -o stl-thumb-kde_${STLTHUMBKDE_API}_armhf.deb || error "Failed to download stl-thumb-kde:armhf!"

    mv stl-thumb-kde* $PKGDIR
    echo $STLTHUMBKDE_API > $STLTHUMBKDE_DATAFILE
    green "stl-thumb-kde downloaded successfully."
fi
green "stl-thumb-kde is up to date."
