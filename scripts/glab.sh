#!/bin/bash

# Core functions
source api
TOKENSCRIPT="/root/token.sh"
if [ ! -f $TOKENSCRIPT ]; then
    error "$TOKENSCRIPT couldn't be found. Exiting."
fi
source $TOKENSCRIPT

status "Updating glab."
GLAB_API=`curl -s --header "Authorization: token $token" https://api.github.com/repos/profclems/glab/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")'`
GLAB_DATAFILE="$HOME/dlfiles-data/glab.txt"
if [ ! -f "$GLAB_DATAFILE" ]; then
    status "$GLAB_DATAFILE does not exist."
    status "Grabbing the latest release from GitHub."
    echo $GLAB_API > $GLAB_DATAFILE
fi
GLAB_CURRENT="$(cat ${GLAB_DATAFILE})"
if [ "$GLAB_CURRENT" != "$GLAB_API" ]; then
    status "glab isn't up to date. updating now..."
    curl -s --header "Authorization: token $token" https://api.github.com/repos/profclems/glab/releases/latest \
      | grep browser_download_url \
      | grep 'arm64.deb"' \
      | cut -d '"' -f 4 \
      | xargs -n 1 curl -L -o glab_${GLAB_API}_arm64.deb || error "Failed to download glab:arm64!"
    curl -s --header "Authorization: token $token" https://api.github.com/repos/profclems/glab/releases/latest \
      | grep browser_download_url \
      | grep 'arm.deb"' \
      | cut -d '"' -f 4 \
      | xargs -n 1 curl -L -o glab_${GLAB_API}_armhf.deb || error "Failed to download glab:armhf!"

    mv glab* $PKGDIR
    echo $GLAB_API > $GLAB_DATAFILE
    green "glab downloaded successfully."
fi
green "glab is up to date."
