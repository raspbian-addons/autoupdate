#!/bin/bash

# Core functions
source api
TOKENSCRIPT="/root/token.sh"
if [ ! -f $TOKENSCRIPT ]; then
    error "$TOKENSCRIPT couldn't be found. Exiting."
fi
source $TOKENSCRIPT

status "Updating myst."
MYST_API=`curl -s --header "Authorization: token $token" https://api.github.com/repos/mysteriumnetwork/node/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")'`
MYST_DATAFILE="$HOME/dlfiles-data/myst.txt"
if [ ! -f "$MYST_DATAFILE" ]; then
    status "$MYST_DATAFILE does not exist."
    status "Grabbing the latest release from GitHub."
    echo $MYST_API > $MYST_DATAFILE
fi
MYST_CURRENT="$(cat ${MYST_DATAFILE})"
if [ "$MYST_CURRENT" != "$MYST_API" ]; then
    status "myst isn't up to date. updating now..."
    curl -s --header "Authorization: token $token" https://api.github.com/repos/mysteriumnetwork/node/releases/latest \
      | grep browser_download_url \
      | grep 'armhf.deb"' \
      | cut -d '"' -f 4 \
      | xargs -n 1 curl -L -o myst_${MYST_API}_armhf.deb || error "Failed to download myst:armhf"

    curl -s --header "Authorization: token $token" https://api.github.com/repos/mysteriumnetwork/node/releases/latest \
      | grep browser_download_url \
      | grep 'arm64.deb"' \
      | cut -d '"' -f 4 \
      | xargs -n 1 curl -L -o myst_${MYST_API}_arm64.deb || error "Failed to download myst:arm64"

    mv myst* $PKGDIR
    echo $MYST_API > $MYST_DATAFILE
    green "myst downloaded successfully."
fi
green "myst is up to date."

