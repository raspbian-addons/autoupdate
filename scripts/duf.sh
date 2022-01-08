#!/bin/bash

# Core functions
source api
TOKENSCRIPT="/root/token.sh"
if [ ! -f $TOKENSCRIPT ]; then
    error "$TOKENSCRIPT couldn't be found. Exiting."
fi
source $TOKENSCRIPT

status "Updating duf."
DUF_API=`curl -s --header "Authorization: token $token" https://api.github.com/repos/muesli/duf/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")'`
DUF_DATAFILE="$HOME/dlfiles-data/duf.txt"
if [ ! -f "$DUF_DATAFILE" ]; then
    status "$DUF_DATAFILE does not exist."
    status "Grabbing the latest release from GitHub."
    echo $DUF_API > $DUF_DATAFILE
fi
DUF_CURRENT="$(cat ${DUF_DATAFILE})"
if [ "$DUF_CURRENT" != "$DUF_API" ]; then
    status "duf isn't up to date. updating now..."
    curl -s --header "Authorization: token $token" https://api.github.com/repos/muesli/duf/releases/latest \
      | grep browser_download_url \
      | grep 'armv7.deb"' \
      | cut -d '"' -f 4 \
      | xargs -n 1 curl -L -o duf_${DUF_API}_armhf.deb || error "Failed to download the duf:armhf"

    curl -s --header "Authorization: token $token" https://api.github.com/repos/muesli/duf/releases/latest \
      | grep browser_download_url \
      | grep 'arm64.deb"' \
      | cut -d '"' -f 4 \
      | xargs -n 1 curl -L -o duf_${DUF_API}_arm64.deb || error "Failed to download duf:arm64"

    mv duf* $PKGDIR
    echo $DUF_API > $DUF_DATAFILE
    green "duf downloaded successfully."
fi
green "duf is up to date."