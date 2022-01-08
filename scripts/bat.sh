#!/bin/bash

# Core functions
source api
TOKENSCRIPT="/root/token.sh"
if [ ! -f $TOKENSCRIPT ]; then
    error "$TOKENSCRIPT couldn't be found. Exiting."
fi
source $TOKENSCRIPT

status "Updating bat."
BAT_API=`curl -s --header "Authorization: token $token" https://api.github.com/repos/sharkdp/bat/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")'`
BAT_DATAFILE="$HOME/dlfiles-data/bat.txt"
if [ ! -f "$BAT_DATAFILE" ]; then
    status "$BAT_DATAFILE does not exist."
    status "Grabbing the latest release from GitHub."
    echo $BAT_API > $BAT_DATAFILE
fi
BAT_CURRENT="$(cat ${BAT_DATAFILE})"
if [ "$BAT_CURRENT" != "$BAT_API" ]; then
    status "bat isn't up to date. updating now..."
    curl -s --header "Authorization: token $token" https://api.github.com/repos/sharkdp/bat/releases/latest \
      | grep browser_download_url \
      | grep 'arm64.deb"' \
      | cut -d '"' -f 4 \
      | xargs -n 1 curl -L -o bat_${BAT_API}_arm64.deb || error "Failed to download bat:arm64!"

    curl -s --header "Authorization: token $token" https://api.github.com/repos/sharkdp/bat/releases/latest \
      | grep browser_download_url \
      | grep 'armhf.deb"' \
      | cut -d '"' -f 4 \
      | xargs -n 1 curl -L -o bat_${BAT_API}_armhf.deb || error "Failed to download bat:armhf!"

    mv bat* $PKGDIR
    echo $BAT_API > $BAT_DATAFILE
    green "bat downloaded successfully."
fi
green "bat is up to date."
