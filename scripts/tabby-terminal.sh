#!/bin/bash

# Core functions
source api
TOKENSCRIPT="/root/token.sh"
if [ ! -f $TOKENSCRIPT ]; then
    error "$TOKENSCRIPT couldn't be found. Exiting."
fi
source $TOKENSCRIPT

status "Updating tabby-terminal."
TABBYTERM_API=`curl -s --header "Authorization: token $token" https://api.github.com/repos/Jai-JAP/tabby-arm-builds/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")'`
TABBYTERM_DATAFILE="$HOME/dlfiles-data/tabby-terminal.txt"
if [ ! -f "$TABBYTERM_DATAFILE" ]; then
    status "$TABBYTERM_DATAFILE does not exist."
    status "Grabbing the latest release from GitHub."
    echo $TABBYTERM_API > $TABBYTERM_DATAFILE
fi
TABBYTERM_CURRENT="$(cat ${TABBYTERM_DATAFILE})"
if [ "$TABBYTERM_CURRENT" != "$TABBYTERM_API" ]; then
    status "tabby-terminal isn't up to date. updating now..."
    curl -s --header "Authorization: token $token" https://api.github.com/repos/Jai-JAP/tabby-arm-builds/releases/latest \
      | grep browser_download_url \
      | grep 'arm64.deb"' \
      | cut -d '"' -f 4 \
      | xargs -n 1 curl -L -o tabby-terminal_${TABBYTERM_API}_arm64.deb || error "Failed to download tabby-terminal:arm64!"
    curl -s --header "Authorization: token $token" https://api.github.com/repos/Jai-JAP/tabby-arm-builds/releases/latest \
      | grep browser_download_url \
      | grep 'armhf.deb"' \
      | cut -d '"' -f 4 \
      | xargs -n 1 curl -L -o tabby-terminal_${TABBYTERM_API}_armhf.deb || error "Failed to download tabby-terminal:armhf!"

    mv tabby* $PKGDIR
    echo $TABBYTERM_API > $TABBYTERM_DATAFILE
    green "tabby-terminal downloaded successfully."
fi
green "tabby-terminal is up to date."
