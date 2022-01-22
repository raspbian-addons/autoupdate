#!/bin/bash

# Core functions
source api
TOKENSCRIPT="/root/token.sh"
if [ ! -f $TOKENSCRIPT ]; then
    error "$TOKENSCRIPT couldn't be found. Exiting."
fi
source $TOKENSCRIPT

status "Updating touchegg."
TOUCHEGG_API=`curl -s --header "Authorization: token $token" https://api.github.com/repos/JoseExposito/touchegg/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")'`
TOUCHEGG_DATAFILE="$HOME/dlfiles-data/touchegg.txt"
if [ ! -f "$TOUCHEGG_DATAFILE" ]; then
    status "$TOUCHEGG_DATAFILE does not exist."
    status "Grabbing the latest release from GitHub."
    echo $TOUCHEGG_API > $TOUCHEGG_DATAFILE
fi
TOUCHEGG_CURRENT="$(cat ${TOUCHEGG_DATAFILE})"
if [ "$TOUCHEGG_CURRENT" != "$TOUCHEGG_API" ]; then
    status "touchegg isn't up to date. updating now..."
    curl -s --header "Authorization: token $token" https://api.github.com/repos/JoseExposito/touchegg/releases/latest \
      | grep browser_download_url \
      | grep 'armhf.deb"' \
      | cut -d '"' -f 4 \
      | xargs -n 1 curl -L -o touchegg_${TOUCHEGG_API}_armhf.deb || error "Failed to download touchegg:armhf"

    curl -s --header "Authorization: token $token" https://api.github.com/repos/JoseExposito/touchegg/releases/latest \
      | grep browser_download_url \
      | grep 'arm64.deb"' \
      | cut -d '"' -f 4 \
      | xargs -n 1 curl -L -o touchegg_${TOUCHEGG_API}_arm64.deb || error "Failed to download touchegg:arm64"

    mv touchegg* $PKGDIR
    echo $TOUCHEGG_API > $TOUCHEGG_DATAFILE
    green "touchegg downloaded successfully."
fi
green "touchegg is up to date."

