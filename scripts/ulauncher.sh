#!/bin/bash

# Core functions
source api
TOKENSCRIPT="/root/token.sh"
if [ ! -f $TOKENSCRIPT ]; then
    error "$TOKENSCRIPT couldn't be found. Exiting."
fi
source $TOKENSCRIPT

status "Updating ulauncher."
ULAUNCHER_API=`curl -s --header "Authorization: token $token" https://api.github.com/repos/Ulauncher/Ulauncher/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")'`
ULAUNCHER_DATAFILE="$HOME/dlfiles-data/ulauncher.txt"
if [ ! -f "$ULAUNCHER_DATAFILE" ]; then
    status "$ULAUNCHER_DATAFILE does not exist."
    status "Grabbing the latest release from GitHub."
    echo $ULAUNCHER_API > $ULAUNCHER_DATAFILE
fi
ULAUNCHER_CURRENT="$(cat ${ULAUNCHER_DATAFILE})"
if [ "$ULAUNCHER_CURRENT" != "$ULAUNCHER_API" ]; then
    status "ulauncher isn't up to date. updating now..."
    curl -s --header "Authorization: token $token" https://api.github.com/repos/Ulauncher/Ulauncher/releases/latest \
      | grep browser_download_url \
      | grep 'all.deb"' \
      | cut -d '"' -f 4 \
      | xargs -n 1 curl -L -o ulauncher_${ULAUNCHER_API}_all.deb || error "Failed to download ulauncher:all!"

    mv ulauncher* $PKGDIR
    echo $ULAUNCHER_API > $ULAUNCHER_DATAFILE
    green "ulauncher downloaded successfully."
fi
green "ulauncher is up to date."
