#!/bin/bash

# Core functions
source api
TOKENSCRIPT="/root/token.sh"
if [ ! -f $TOKENSCRIPT ]; then
    error "$TOKENSCRIPT couldn't be found. Exiting."
fi
source $TOKENSCRIPT

status "Updating teams-for-linux."
TFL_API=`curl -s --header "Authorization: token $token" https://api.github.com/repos/IsmaelMartinez/teams-for-linux/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")'`
TFL_DATAFILE="$HOME/dlfiles-data/teams-for-linux.txt"
if [ ! -f "$TFL_DATAFILE" ]; then
    status "$TFL_DATAFILE does not exist."
    status "Grabbing the latest release from GitHub."
    echo $TFL_API > $TFL_DATAFILE
fi
TFL_CURRENT="$(cat ${TFL_DATAFILE})"
if [ "$TFL_CURRENT" != "$TFL_API" ]; then
    status "teams-for-linux isn't up to date. updating now..."
    curl -s --header "Authorization: token $token" https://api.github.com/repos/IsmaelMartinez/teams-for-linux/releases/latest \
      | grep browser_download_url \
      | grep 'arm64.deb"' \
      | cut -d '"' -f 4 \
      | xargs -n 1 curl -L -o teams-for-linux_${TFL_API}_arm64.deb || error "Failed to download teams-for-linux:arm64!"
    curl -s --header "Authorization: token $token" https://api.github.com/repos/IsmaelMartinez/teams-for-linux/releases/latest \
      | grep browser_download_url \
      | grep 'armv7l.deb"' \
      | cut -d '"' -f 4 \
      | xargs -n 1 curl -L -o teams-for-linux_${TFL_API}_armhf.deb || error "Failed to download teams-for-linux:armhf!"

    mv teams-for-linux* $PKGDIR
    echo $TFL_API > $TFL_DATAFILE
    green "teams-for-linux downloaded successfully."
fi
green "teams-for-linux is up to date."
