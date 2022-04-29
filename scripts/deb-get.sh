#!/bin/bash

# Core functions
source api
TOKENSCRIPT="/root/token.sh"
if [ ! -f $TOKENSCRIPT ]; then
    error "$TOKENSCRIPT couldn't be found. Exiting."
fi
source $TOKENSCRIPT

status "Updating deb-get."
DEBGET_API=`curl -s --header "Authorization: token $token" https://api.github.com/repos/wimpysworld/deb-get/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")'`
DEBGET_DATAFILE="$HOME/dlfiles-data/deb-get.txt"
if [ ! -f "$DEBGET_DATAFILE" ]; then
    status "$DEBGET_DATAFILE does not exist."
    status "Grabbing the latest release from GitHub."
    echo $DEBGET_API > $DEBGET_DATAFILE
fi
DEBGET_CURRENT="$(cat ${DEBGET_DATAFILE})"
if [ "$DEBGET_CURRENT" != "$DEBGET_API" ]; then
    status "deb-get isn't up to date. updating now..."
    curl -s --header "Authorization: token $token" https://api.github.com/repos/wimpysworld/deb-get/releases/latest \
      | grep browser_download_url \
      | grep 'all.deb"' \
      | cut -d '"' -f 4 \
      | xargs -n 1 curl -L -o deb-get_${DEBGET_API}_all.deb || error "Failed to download deb-get:all!"

    mv deb-get* $PKGDIR
    echo $DEBGET_API > $DEBGET_DATAFILE
    green "deb-get downloaded successfully."
fi
green "deb-get is up to date."
