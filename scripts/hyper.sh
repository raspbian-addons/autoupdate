#!/bin/bash

# Core functions
source api
TOKENSCRIPT="/root/token.sh"
if [ ! -f $TOKENSCRIPT ]; then
    error "$TOKENSCRIPT couldn't be found. Exiting."
fi
source $TOKENSCRIPT

status "Updating hyper."
HYPER_API=`curl -s --header "Authorization: token $token" https://api.github.com/repos/vercel/hyper/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")'`
HYPER_DATAFILE="$HOME/dlfiles-data/hyper.txt"
if [ ! -f "$HYPER_DATAFILE" ]; then
    status "$HYPER_DATAFILE does not exist."
    status "Grabbing the latest release from GitHub."
    echo $HYPER_API > $HYPER_DATAFILE
fi
HYPER_CURRENT="$(cat ${HYPER_DATAFILE})"
if [ "$HYPER_CURRENT" != "$HYPER_API" ]; then
    status "hyper isn't up to date. updating now..."
    curl -s --header "Authorization: token $token" https://api.github.com/repos/vercel/hyper/releases/latest \
      | grep browser_download_url \
      | grep 'arm64.deb"' \
      | cut -d '"' -f 4 \
      | xargs -n 1 curl -L -o hyper_${HYPER_API}_arm64.deb || error "Failed to download the hyper:arm64"

    mv hyper* $PKGDIR
    echo $HYPER_API > $HYPER_DATAFILE
    green "hyper downloaded successfully."
fi
green "hyper is up to date."