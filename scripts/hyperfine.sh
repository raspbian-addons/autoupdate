#!/bin/bash

# Core functions
source api
TOKENSCRIPT="/root/token.sh"
if [ ! -f $TOKENSCRIPT ]; then
    error "$TOKENSCRIPT couldn't be found. Exiting."
fi
source $TOKENSCRIPT

status "Updating hyperfine."
HYPERFINE_API=`curl -s --header "Authorization: token $token" https://api.github.com/repos/sharkdp/hyperfine/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")'`
HYPERFINE_DATAFILE="$HOME/dlfiles-data/hyperfine.txt"
if [ ! -f "$HYPERFINE_DATAFILE" ]; then
    status "$HYPERFINE_DATAFILE does not exist."
    status "Grabbing the latest release from GitHub."
    echo $HYPERFINE_API > $HYPERFINE_DATAFILE
fi
HYPERFINE_CURRENT="$(cat ${HYPERFINE_DATAFILE})"
if [ "$HYPERFINE_CURRENT" != "$HYPERFINE_API" ]; then
    status "hyperfine isn't up to date. updating now..."
    curl -s --header "Authorization: token $token" https://api.github.com/repos/sharkdp/hyperfine/releases/latest \
      | grep browser_download_url \
      | grep 'armhf.deb"' \
      | cut -d '"' -f 4 \
      | xargs -n 1 curl -L -o hyperfine_${HYPERFINE_API}_armhf.deb || error "Failed to download hyperfine:armhf"

    curl -s --header "Authorization: token $token" https://api.github.com/repos/sharkdp/hyperfine/releases/latest \
      | grep browser_download_url \
      | grep 'arm64.deb"' \
      | cut -d '"' -f 4 \
      | xargs -n 1 curl -L -o hyperfine_${HYPERFINE_API}_arm64.deb || error "Failed to download hyperfine:arm64"

    mv hyperfine* $PKGDIR
    echo $HYPERFINE_API > $HYPERFINE_DATAFILE
    green "hyperfine downloaded successfully."
fi
green "hyperfine is up to date."
