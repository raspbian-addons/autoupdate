#!/bin/bash

# Core functions
source api
TOKENSCRIPT="/root/token.sh"
if [ ! -f $TOKENSCRIPT ]; then
    error "$TOKENSCRIPT couldn't be found. Exiting."
fi
source $TOKENSCRIPT

status "Updating gh."
GH_API=`curl -s --header "Authorization: token $token" https://api.github.com/repos/cli/cli/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")'`
GH_DATAFILE="$HOME/dlfiles-data/gh.txt"
if [ ! -f "$GH_DATAFILE" ]; then
    status "$GH_DATAFILE does not exist."
    status "Grabbing the latest release from GitHub."
    echo $GH_API > $GH_DATAFILE
fi
GH_CURRENT="$(cat ${GH_DATAFILE})"
if [ "$GH_CURRENT" != "$GH_API" ]; then
    status "gh isn't up to date. updating now..."
    curl -s --header "Authorization: token $token" https://api.github.com/repos/cli/cli/releases/latest \
      | grep browser_download_url \
      | grep 'arm64.deb"' \
      | cut -d '"' -f 4 \
      | xargs -n 1 curl -L -o gh_${GH_API}_arm64.deb || error "Failed to download gh:arm64!"
    curl -s --header "Authorization: token $token" https://api.github.com/repos/cli/cli/releases/latest \
      | grep browser_download_url \
      | grep 'armv6.deb"' \
      | cut -d '"' -f 4 \
      | xargs -n 1 curl -L -o gh_${GH_API}_armhf.deb || error "Failed to download gh:armhf!"

    mv gh* $PKGDIR
    echo $GH_API > $GH_DATAFILE
    green "gh downloaded successfully."
fi
green "gh is up to date."
