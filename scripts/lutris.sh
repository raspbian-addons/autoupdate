#!/bin/bash

# Core functions
source api
TOKENSCRIPT="/root/token.sh"
if [ ! -f $TOKENSCRIPT ]; then
    error "$TOKENSCRIPT couldn't be found. Exiting."
fi
source $TOKENSCRIPT

status "Updating lutris."
LUTRIS_API=`curl -s --header "Authorization: token $token" https://api.github.com/repos/lutris/lutris/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")'`
LUTRIS_DATAFILE="$HOME/dlfiles-data/lutris.txt"
if [ ! -f "$LUTRIS_DATAFILE" ]; then
    status "$LUTRIS_DATAFILE does not exist."
    status "Grabbing the latest release from GitHub."
    echo $LUTRIS_API > $LUTRIS_DATAFILE
fi
LUTRIS_CURRENT="$(cat ${LUTRIS_DATAFILE})"
if [ "$LUTRIS_CURRENT" != "$LUTRIS_API" ]; then
    status "lutris isn't up to date. updating now..."
    curl -s --header "Authorization: token $token" https://api.github.com/repos/lutris/lutris/releases/latest \
      | grep browser_download_url \
      | grep 'all.deb"' \
      | cut -d '"' -f 4 \
      | xargs -n 1 curl -L -o lutris_${LUTRIS_API}_all.deb || error "Failed to download lutris:all!"

    mv lutris* $PKGDIR
    echo $LUTRIS_API > $LUTRIS_DATAFILE
    green "lutris downloaded successfully."
fi
green "lutris is up to date."
