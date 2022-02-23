#!/bin/bash

# Core functions
source api
TOKENSCRIPT="/root/token.sh"
if [ ! -f $TOKENSCRIPT ]; then
    error "$TOKENSCRIPT couldn't be found. Exiting."
fi
source $TOKENSCRIPT

status "Updating ipsw."
IPSW_API=`curl -s --header "Authorization: token $token" https://api.github.com/repos/blacktop/ipsw/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")' | tr -d 'v'`
IPSW_DATAFILE="$HOME/dlfiles-data/ipsw.txt"
if [ ! -f "$IPSW_DATAFILE" ]; then
    status "$IPSW_DATAFILE does not exist."
    status "Grabbing the latest release from GitHub."
    echo $IPSW_API > $IPSW_DATAFILE
fi
IPSW_CURRENT="$(cat ${IPSW_DATAFILE})"
if [ "$IPSW_CURRENT" != "$IPSW_API" ]; then
    status "ipsw isn't up to date. updating now..."
    curl -s --header "Authorization: token $token" https://api.github.com/repos/blacktop/ipsw/releases/latest \
      | grep browser_download_url \
      | grep 'arm64.deb"' \
      | cut -d '"' -f 4 \
      | xargs -n 1 curl -L -o ipsw_${IPSW_API}_arm64.deb || error "Failed to download ipsw:arm64!"
      
    mv ipsw* $PKGDIR
    echo $IPSW_API > $IPSW_DATAFILE
    green "ipsw downloaded successfully."
fi
green "ipsw is up to date."
