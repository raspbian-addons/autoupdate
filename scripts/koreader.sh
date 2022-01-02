#!/bin/bash

# Core functions
source api
TOKENSCRIPT="/root/token.sh"
if [ ! -f $TOKENSCRIPT ]; then
    error "$TOKENSCRIPT couldn't be found. Exiting."
fi
source $TOKENSCRIPT

status "Updating koreader."
KOREADER_API=`curl -s --header "Authorization: token $token" https://api.github.com/repos/koreader/koreader/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")'`
KOREADER_DATAFILE="$HOME/dlfiles-data/koreader.txt"
if [ ! -f "$KOREADER_DATAFILE" ]; then
    status "$KOREADER_DATAFILE does not exist."
    status "Grabbing the latest release from GitHub."
    echo $KOREADER_API > $KOREADER_DATAFILE
fi
KOREADER_CURRENT="$(cat ${KOREADER_DATAFILE})"
if [ "$KOREADER_CURRENT" != "$KOREADER_API" ]; then
    status "koreader isn't up to date. updating now..."
    curl -s --header "Authorization: token $token" https://api.github.com/repos/koreader/koreader/releases/latest \
      | grep browser_download_url \
      | grep 'armhf.deb"' \
      | cut -d '"' -f 4 \
      | xargs -n 1 curl -L -o koreader_${KOREADER_API}_armhf.deb || error "Failed to download koreader:armhf!"
    curl -s --header "Authorization: token $token" https://api.github.com/repos/koreader/koreader/releases/latest \
      | grep browser_download_url \
      | grep 'arm64.deb"' \
      | cut -d '"' -f 4 \
      | xargs -n 1 curl -L -o koreader_${KOREADER_API}_arm64.deb || error "Failed to download koreader:arm64!"

    mv koreader* $PKGDIR
    echo $KOREADER_API > $KOREADER_DATAFILE
    green "koreader downloaded successfully."
fi
green "koreader is up to date."
