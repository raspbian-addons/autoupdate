#!/bin/bash

# Core functions
source api
TOKENSCRIPT="/root/token.sh"
if [ ! -f $TOKENSCRIPT ]; then
    error "$TOKENSCRIPT couldn't be found. Exiting."
fi
source $TOKENSCRIPT

status "Updating lx-music-desktop."
LMD_API=`curl -s --header "Authorization: token $token" https://api.github.com/repos/lyswhut/lx-music-desktop/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")'`
LMD_DATAFILE="$HOME/dlfiles-data/lx-music-desktop.txt"
if [ ! -f "$LMD_DATAFILE" ]; then
    status "$LMD_DATAFILE does not exist."
    status "Grabbing the latest release from GitHub."
    echo $LMD_API > $LMD_DATAFILE
fi
LMD_CURRENT="$(cat ${LMD_DATAFILE})"
if [ "$LMD_CURRENT" != "$LMD_API" ]; then
    status "lx-music-desktop isn't up to date. updating now..."
    curl -s --header "Authorization: token $token" https://api.github.com/repos/lyswhut/lx-music-desktop/releases/latest \
      | grep browser_download_url \
      | grep 'arm64.deb"' \
      | cut -d '"' -f 4 \
      | xargs -n 1 curl -L -o lx-music-desktop_${LMD_API}_arm64.deb || error "Failed to download lx-music-desktop:arm64!"
    curl -s --header "Authorization: token $token" https://api.github.com/repos/lyswhut/lx-music-desktop/releases/latest \
      | grep browser_download_url \
      | grep 'armv7l.deb"' \
      | cut -d '"' -f 4 \
      | xargs -n 1 curl -L -o lx-music-desktop_${LMD_API}_armhf.deb || error "Failed to download lx-music-desktop:armhf!"

    mv lx-music-desktop* $PKGDIR
    echo $LMD_API > $LMD_DATAFILE
    green "lx-music-desktop downloaded successfully."
fi
green "lx-music-desktop is up to date."
