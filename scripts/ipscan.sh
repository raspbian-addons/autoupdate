#!/bin/bash

# Core functions
source api
TOKENSCRIPT="/root/token.sh"
if [ ! -f $TOKENSCRIPT ]; then
    error "$TOKENSCRIPT couldn't be found. Exiting."
fi
source $TOKENSCRIPT

status "Updating ipscan."
IPSCAN_API=`curl -s --header "Authorization: token $token" https://api.github.com/repos/angryip/ipscan/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")'`
IPSCAN_DATAFILE="$HOME/dlfiles-data/ipscan.txt"
if [ ! -f "$IPSCAN_DATAFILE" ]; then
    status "$IPSCAN_DATAFILE does not exist."
    status "Grabbing the latest release from GitHub."
    echo $IPSCAN_API > $IPSCAN_DATAFILE
fi
IPSCAN_CURRENT="$(cat ${IPSCAN_DATAFILE})"
if [ "$IPSCAN_CURRENT" != "$IPSCAN_API" ]; then
    status "ipscan isn't up to date. updating now..."
    curl -s --header "Authorization: token $token" https://api.github.com/repos/angryip/ipscan/releases/latest \
      | grep browser_download_url \
      | grep 'all.deb"' \
      | cut -d '"' -f 4 \
      | xargs -n 1 curl -L -o ipscan_${IPSCAN_API}_all.deb || error "Failed to download ipscan:all!"

    mv ipscan* $PKGDIR
    echo $IPSCAN_API > $IPSCAN_DATAFILE
    green "ipscan downloaded successfully."
fi
green "ipscan is up to date."
