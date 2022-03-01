#!/bin/bash

# Core functions
source api
TOKENSCRIPT="/root/token.sh"
if [ ! -f $TOKENSCRIPT ]; then
    error "$TOKENSCRIPT couldn't be found. Exiting."
fi
source $TOKENSCRIPT

status "Updating ferdi."
FERDI_API=`curl -s --header "Authorization: token $token" https://api.github.com/repos/getferdi/ferdi/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")'`
FERDI_DATAFILE="$HOME/dlfiles-data/ferdi.txt"
if [ ! -f "$FERDI_DATAFILE" ]; then
    status "$FERDI_DATAFILE does not exist."
    status "Grabbing the latest release from GitHub."
    echo $FERDI_API > $FERDI_DATAFILE
fi
FERDI_CURRENT="$(cat ${FERDI_DATAFILE})"
if [ "$FERDI_CURRENT" != "$FERDI_API" ]; then
    status "ferdi isn't up to date. updating now..."
    curl -s --header "Authorization: token $token" https://api.github.com/repos/getferdi/ferdi/releases/latest \
      | grep browser_download_url \
      | grep 'arm64.deb"' \
      | cut -d '"' -f 4 \
      | xargs -n 1 curl -L -o ferdi_${FERDI_API}_arm64.deb || error "Failed to download ferdi:arm64!"
    curl -s --header "Authorization: token $token" https://api.github.com/repos/getferdi/ferdi/releases/latest \
      | grep browser_download_url \
      | grep 'armv7l.deb"' \
      | cut -d '"' -f 4 \
      | xargs -n 1 curl -L -o ferdi_${FERDI_API}_armhf.deb || error "Failed to download ferdi:armhf!"

    mv ferdi* $PKGDIR
    echo $FERDI_API > $FERDI_DATAFILE
    green "ferdi downloaded successfully."
fi
green "ferdi is up to date."
