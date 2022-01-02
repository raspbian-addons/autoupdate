#!/bin/bash

# Core functions
source api
TOKENSCRIPT="/root/token.sh"
if [ ! -f $TOKENSCRIPT ]; then
    error "$TOKENSCRIPT couldn't be found. Exiting."
fi
source $TOKENSCRIPT

status "Updating webcord."
WEBCORD_API=`curl -s --header "Authorization: token $token" https://api.github.com/repos/SpacingBat3/WebCord/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")'`
WEBCORD_DATAFILE="$HOME/dlfiles-data/webcord.txt"
if [ ! -f "$WEBCORD_DATAFILE" ]; then
    status "$WEBCORD_DATAFILE does not exist."
    status "Grabbing the latest release from GitHub."
    echo $WEBCORD_API > $WEBCORD_DATAFILE
fi
WEBCORD_CURRENT="$(cat ${WEBCORD_DATAFILE})"
if [ "$WEBCORD_CURRENT" != "$WEBCORD_API" ]; then
    status "webcord isn't up to date. updating now..."
    curl -s --header "Authorization: token $token" https://api.github.com/repos/SpacingBat3/WebCord/releases/latest \
      | grep browser_download_url \
      | grep 'armhf.deb"' \
      | cut -d '"' -f 4 \
      | xargs -n 1 curl -L -o webcord_${WEBCORD_API}_armhf.deb || error "Failed to download webcord:armhf"

    curl -s --header "Authorization: token $token" https://api.github.com/repos/SpacingBat3/WebCord/releases/latest \
      | grep browser_download_url \
      | grep 'arm64.deb"' \
      | cut -d '"' -f 4 \
      | xargs -n 1 curl -L -o webcord_${WEBCORD_API}_arm64.deb || error "Failed to download webcord:arm64"

    mv webcord* $PKGDIR
    echo $WEBCORD_API > $WEBCORD_DATAFILE
    green "webcord downloaded successfully."
fi
green "webcord is up to date."

