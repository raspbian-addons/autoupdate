#!/bin/bash

# Core functions
source api
TOKENSCRIPT="/root/token.sh"
if [ ! -f $TOKENSCRIPT ]; then
    error "$TOKENSCRIPT couldn't be found. Exiting."
fi
source $TOKENSCRIPT

status "Updating howdy."
HOWDY_API=`curl -s --header "Authorization: token $token" https://api.github.com/repos/boltgolt/howdy/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")'`
HOWDY_DATAFILE="$HOME/dlfiles-data/howdy.txt"
if [ ! -f "$HOWDY_DATAFILE" ]; then
    status "$HOWDY_DATAFILE does not exist."
    status "Grabbing the latest release from GitHub."
    echo $HOWDY_API > $HOWDY_DATAFILE
fi
HOWDY_CURRENT="$(cat ${HOWDY_DATAFILE})"
if [ "$HOWDY_CURRENT" != "$HOWDY_API" ]; then
    status "howdy isn't up to date. updating now..."
    curl -s --header "Authorization: token $token" https://api.github.com/repos/boltgolt/howdy/releases/latest \
      | grep browser_download_url \
      | grep '.deb"' \
      | cut -d '"' -f 4 \
      | xargs -n 1 curl -L -o howdy_${HOWDY_API}_all.deb || error "Failed to download howdy:all!"

    mv howdy* $PKGDIR
    echo $HOWDY_API > $HOWDY_DATAFILE
    green "howdy downloaded successfully."
fi
green "howdy is up to date."
