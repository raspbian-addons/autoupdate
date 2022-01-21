#!/bin/bash

# Core functions
source api
TOKENSCRIPT="/root/token.sh"
if [ ! -f $TOKENSCRIPT ]; then
    error "$TOKENSCRIPT couldn't be found. Exiting."
fi
source $TOKENSCRIPT

status "Updating fiddle."
FIDDLE_API=`curl -s --header "Authorization: token $token" https://api.github.com/repos/electron/fiddle/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")'`
FIDDLE_DATAFILE="$HOME/dlfiles-data/fiddle.txt"
if [ ! -f "$FIDDLE_DATAFILE" ]; then
    status "$FIDDLE_DATAFILE does not exist."
    status "Grabbing the latest release from GitHub."
    echo $FIDDLE_API > $FIDDLE_DATAFILE
fi
FIDDLE_CURRENT="$(cat ${FIDDLE_DATAFILE})"
if [ "$FIDDLE_CURRENT" != "$FIDDLE_API" ]; then
    status "fiddle isn't up to date. updating now..."
    curl -s --header "Authorization: token $token" https://api.github.com/repos/electron/fiddle/releases/latest \
      | grep browser_download_url \
      | grep 'arm64.deb"' \
      | cut -d '"' -f 4 \
      | xargs -n 1 curl -L -o fiddle_${FIDDLE_API}_arm64.deb || error "Failed to download fiddle:arm64!"

    curl -s --header "Authorization: token $token" https://api.github.com/repos/electron/fiddle/releases/latest \
      | grep browser_download_url \
      | grep 'armhf.deb"' \
      | cut -d '"' -f 4 \
      | xargs -n 1 curl -L -o fiddle_${FIDDLE_API}_armhf.deb || error "Failed to download fiddle:armhf!"

    mv fiddle* $PKGDIR
    echo $FIDDLE_API > $FIDDLE_DATAFILE
    green "fiddle downloaded successfully."
fi
green "fiddle is up to date."
