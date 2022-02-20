#!/bin/bash

# Core functions
source api
TOKENSCRIPT="/root/token.sh"
if [ ! -f $TOKENSCRIPT ]; then
    error "$TOKENSCRIPT couldn't be found. Exiting."
fi
source $TOKENSCRIPT

status "Updating caddy."
CADDY_API=`curl -s --header "Authorization: token $token" https://api.github.com/repos/caddyserver/caddy/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")'`
CADDY_DATAFILE="$HOME/dlfiles-data/caddy.txt"
if [ ! -f "$CADDY_DATAFILE" ]; then
    status "$CADDY_DATAFILE does not exist."
    status "Grabbing the latest release from GitHub."
    echo $CADDY_API > $CADDY_DATAFILE
fi
CADDY_CURRENT="$(cat ${CADDY_DATAFILE})"
if [ "$CADDY_CURRENT" != "$CADDY_API" ]; then
    status "caddy isn't up to date. updating now..."
    curl -s --header "Authorization: token $token" https://api.github.com/repos/caddyserver/caddy/releases/latest \
      | grep browser_download_url \
      | grep 'arm64.deb"' \
      | cut -d '"' -f 4 \
      | xargs -n 1 curl -L -o caddy_${CADDY_API}_arm64.deb || error "Failed to download caddy:arm64!"
    curl -s --header "Authorization: token $token" https://api.github.com/repos/caddyserver/caddy/releases/latest \
      | grep browser_download_url \
      | grep 'armv7.deb"' \
      | cut -d '"' -f 4 \
      | xargs -n 1 curl -L -o caddy_${CADDY_API}_armhf.deb || error "Failed to download caddy:armhf!"

    mv caddy* $PKGDIR
    echo $CADDY_API > $CADDY_DATAFILE
    green "caddy downloaded successfully."
fi
green "caddy is up to date."
