#!/bin/bash

# Core functions
source api
TOKENSCRIPT="/root/token.sh"
if [ ! -f $TOKENSCRIPT ]; then
    error "$TOKENSCRIPT couldn't be found. Exiting."
fi
source $TOKENSCRIPT

status "Updating ducopanel."
DUCOPANEL_API=`curl -s --header "Authorization: token $token" https://api.github.com/repos/ponsato/ducopanel/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")'`
DUCOPANEL_DATAFILE="$HOME/dlfiles-data/ducopanel.txt"
if [ ! -f "$DUCOPANEL_DATAFILE" ]; then
    status "$DUCOPANEL_DATAFILE does not exist."
    status "Grabbing the latest release from GitHub."
    echo $DUCOPANEL_API > $DUCOPANEL_DATAFILE
fi
DUCOPANEL_CURRENT="$(cat ${DUCOPANEL_DATAFILE})"
if [ "$DUCOPANEL_CURRENT" != "$DUCOPANEL_API" ]; then
    status "ducopanel isn't up to date. updating now..."
    curl -s --header "Authorization: token $token" https://api.github.com/repos/ponsato/ducopanel/releases/latest \
      | grep browser_download_url \
      | grep 'arm64.deb"' \
      | cut -d '"' -f 4 \
      | xargs -n 1 curl -L -o ducopanel_${DUCOPANEL_API}_arm64.deb || error "Failed to download ducopanel:arm64"

    mv ducopanel* $PKGDIR
    echo $DUCOPANEL_API > $DUCOPANEL_DATAFILE
    green "ducopanel downloaded successfully."
fi
green "ducopanel is up to date."