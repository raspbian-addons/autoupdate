#!/bin/bash

# Core functions
source api
TOKENSCRIPT="/root/token.sh"
if [ ! -f $TOKENSCRIPT ]; then
    error "$TOKENSCRIPT couldn't be found. Exiting."
fi
source $TOKENSCRIPT

status "Updating grype."
GRYPE_API=`curl -s --header "Authorization: token $token" https://api.github.com/repos/anchore/grype/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")'`
GRYPE_DATAFILE="$HOME/dlfiles-data/grype.txt"
if [ ! -f "$GRYPE_DATAFILE" ]; then
    status "$GRYPE_DATAFILE does not exist."
    status "Grabbing the latest release from GitHub."
    echo $GRYPE_API > $GRYPE_DATAFILE
fi
GRYPE_CURRENT="$(cat ${GRYPE_DATAFILE})"
if [ "$GRYPE_CURRENT" != "$GRYPE_API" ]; then
    status "grype isn't up to date. updating now..."
    curl -s --header "Authorization: token $token" https://api.github.com/repos/anchore/grype/releases/latest \
      | grep browser_download_url \
      | grep 'arm64.deb"' \
      | cut -d '"' -f 4 \
      | xargs -n 1 curl -L -o grype_${GRYPE_API}_arm64.deb || error "Failed to download grype:arm64!"

    mv grype* $PKGDIR
    echo $GRYPE_API > $GRYPE_DATAFILE
    green "grype downloaded successfully."
fi
green "grype is up to date."
