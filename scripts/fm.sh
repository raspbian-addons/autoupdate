#!/bin/bash

# Core functions
source api
TOKENSCRIPT="/root/token.sh"
if [ ! -f $TOKENSCRIPT ]; then
    error "$TOKENSCRIPT couldn't be found. Exiting."
fi
source $TOKENSCRIPT

status "Updating fm."
FM_API=`curl -s --header "Authorization: token $token" https://api.github.com/repos/knipferrc/fm/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")'`
FM_DATAFILE="$HOME/dlfiles-data/fm.txt"
if [ ! -f "$FM_DATAFILE" ]; then
    status "$FM_DATAFILE does not exist."
    status "Grabbing the latest release from GitHub."
    echo $FM_API > $FM_DATAFILE
fi
FM_CURRENT="$(cat ${FM_DATAFILE})"
if [ "$FM_CURRENT" != "$FM_API" ]; then
    status "fm isn't up to date. updating now..."
    curl -s --header "Authorization: token $token" https://api.github.com/repos/knipferrc/fm/releases/latest \
      | grep browser_download_url \
      | grep 'arm64.deb"' \
      | cut -d '"' -f 4 \
      | xargs -n 1 curl -L -o fm_${FM_API}_arm64.deb || error "Failed to download fm:arm64!"

    mv fm* $PKGDIR
    echo $FM_API > $FM_DATAFILE
    green "fm downloaded successfully."
fi
green "fm is up to date."
