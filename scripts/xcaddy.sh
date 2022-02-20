#!/bin/bash

# Core functions
source api
TOKENSCRIPT="/root/token.sh"
if [ ! -f $TOKENSCRIPT ]; then
    error "$TOKENSCRIPT couldn't be found. Exiting."
fi
source $TOKENSCRIPT

status "Updating xcaddy."
XCADDY_API=`curl -s --header "Authorization: token $token" https://api.github.com/repos/caddyserver/xcaddy/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")'`
XCADDY_DATAFILE="$HOME/dlfiles-data/caddy.txt"
if [ ! -f "$XCADDY_DATAFILE" ]; then
    status "$XCADDY_DATAFILE does not exist."
    status "Grabbing the latest release from GitHub."
    echo $XCADDY_API > $XCADDY_DATAFILE
fi
XCADDY_CURRENT="$(cat ${XCADDY_DATAFILE})"
if [ "$XCADDY_CURRENT" != "$XCADDY_API" ]; then
    status "xcaddy isn't up to date. updating now..."
    curl -s --header "Authorization: token $token" https://api.github.com/repos/caddyserver/xcaddy/releases/latest \
      | grep browser_download_url \
      | grep 'arm64.deb"' \
      | cut -d '"' -f 4 \
      | xargs -n 1 curl -L -o xcaddy_${XCADDY_API}_arm64.deb || error "Failed to download xcaddy:arm64!"
    curl -s --header "Authorization: token $token" https://api.github.com/repos/caddyserver/xcaddy/releases/latest \
      | grep browser_download_url \
      | grep 'armv7.deb"' \
      | cut -d '"' -f 4 \
      | xargs -n 1 curl -L -o xcaddy_${XCADDY_API}_armhf.deb || error "Failed to download xcaddy:armhf!"

    mv xcaddy* $PKGDIR
    echo $XCADDY_API > $XCADDY_DATAFILE
    green "xcaddy downloaded successfully."
fi
green "xcaddy is up to date."
