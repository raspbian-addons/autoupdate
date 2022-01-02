#!/bin/bash

# Core functions
source api
TOKENSCRIPT="/root/token.sh"
if [ ! -f $TOKENSCRIPT ]; then
    error "$TOKENSCRIPT couldn't be found. Exiting."
fi
source $TOKENSCRIPT

status "Updating min."
MIN_API=`curl -s --header "Authorization: token $token" https://api.github.com/repos/minbrowser/min/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")'`
MIN_DATAFILE="$HOME/dlfiles-data/min.txt"
if [ ! -f "$MIN_DATAFILE" ]; then
    status "$MIN_DATAFILE does not exist."
    status "Grabbing the latest release from GitHub."
    echo $MIN_API > $MIN_DATAFILE
fi
MIN_CURRENT="$(cat ${MIN_DATAFILE})"
if [ "$MIN_CURRENT" != "$MIN_API" ]; then
    status "min isn't up to date. updating now..."
    curl -s --header "Authorization: token $token" https://api.github.com/repos/minbrowser/min/releases/latest \
      | grep browser_download_url \
      | grep 'arm64.deb"' \
      | cut -d '"' -f 4 \
      | xargs -n 1 curl -L -o min_${MIN_API}_arm64.deb || error "Failed to download min:arm64!"
    curl -s --header "Authorization: token $token" https://api.github.com/repos/minbrowser/min/releases/latest \
      | grep browser_download_url \
      | grep 'armhf.deb"' \
      | cut -d '"' -f 4 \
      | xargs -n 1 curl -L -o min_${MIN_API}_armhf.deb || error "Failed to download min:armhf!"

    mv min* $PKGDIR
    echo $MIN_API > $MIN_DATAFILE
    green "min downloaded successfully."
fi
green "min is up to date."
