#!/bin/bash

# Core functions
source api
TOKENSCRIPT="/root/token.sh"
if [ ! -f $TOKENSCRIPT ]; then
    error "$TOKENSCRIPT couldn't be found. Exiting."
fi
source $TOKENSCRIPT

status "Updating cloudflared."
CLOUDFLARED_API=`curl -s --header "Authorization: token $token" https://api.github.com/repos/cloudflare/cloudflared/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")'`
CLOUDFLARED_DATAFILE="$HOME/dlfiles-data/cloudflared.txt"
if [ ! -f "$CLOUDFLARED_DATAFILE" ]; then
    status "$CLOUDFLARED_DATAFILE does not exist."
    status "Grabbing the latest release from GitHub."
    echo $CLOUDFLARED_API > $CLOUDFLARED_DATAFILE
fi
CLOUDFLARED_CURRENT="$(cat ${CLOUDFLARED_DATAFILE})"
if [ "$CLOUDFLARED_CURRENT" != "$CLOUDFLARED_API" ]; then
    status "cloudflared isn't up to date. updating now..."
    curl -s --header "Authorization: token $token" https://api.github.com/repos/cloudflare/cloudflared/releases/latest \
      | grep browser_download_url \
      | grep 'arm64.deb"' \
      | cut -d '"' -f 4 \
      | xargs -n 1 curl -L -o cloudflared_${CLOUDFLARED_API}_arm64.deb || error "Failed to download cloudflared:arm64!"
    curl -s --header "Authorization: token $token" https://api.github.com/repos/cloudflare/cloudflared/releases/latest \
      | grep browser_download_url \
      | grep 'arm.deb"' \
      | cut -d '"' -f 4 \
      | xargs -n 1 curl -L -o cloudflared_${CLOUDFLARED_API}_armhf.deb || error "Failed to download cloudflared:armhf!"

    mv cloudflared* $PKGDIR
    echo $CLOUDFLARED_API > $CLOUDFLARED_DATAFILE
    green "cloudflared downloaded successfully."
fi
green "cloudflared is up to date."
