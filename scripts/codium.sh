#!/bin/bash

status "Updating codium."
CODIUM_API=`curl -s --header "Authorization: token $token" https://api.github.com/repos/VSCodium/VSCodium/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")'`
CODIUM_DATAFILE="$HOME/dlfiles-data/codium.txt"
if [ ! -f "$CODIUM_DATAFILE" ]; then
    status "$CODIUM_DATAFILE does not exist."
    status "Grabbing the latest release from GitHub."
    echo $CODIUM_API > $CODIUM_DATAFILE
fi
CODIUM_CURRENT="$(cat ${CODIUM_DATAFILE})"
if [ "$CODIUM_CURRENT" != "$CODIUM_API" ]; then
    status "codium isn't up to date. updating now..."
    curl -s --header "Authorization: token $token" https://api.github.com/repos/VSCodium/VSCodium/releases/latest \
      | grep browser_download_url \
      | grep 'armhf.deb"' \
      | cut -d '"' -f 4 \
      | xargs -n 1 curl -L -o codium_${CODIUM_API}_armhf.deb || error "Failed to download the codium:armhf"

    curl -s --header "Authorization: token $token" https://api.github.com/repos/VSCodium/VSCodium/releases/latest \
      | grep browser_download_url \
      | grep 'arm64.deb"' \
      | cut -d '"' -f 4 \
      | xargs -n 1 curl -L -o codium_${CODIUM_API}_arm64.deb || error "Failed to download codium:arm64"

    mv codium* $PKGDIR
    echo $CODIUM_API > $CODIUM_DATAFILE
    green "codium downloaded successfully."
fi
green "codium is up to date."