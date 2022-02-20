#!/bin/bash

# Core functions
source api
TOKENSCRIPT="/root/token.sh"
if [ ! -f $TOKENSCRIPT ]; then
    error "$TOKENSCRIPT couldn't be found. Exiting."
fi
source $TOKENSCRIPT

status "Updating figma-linux."
FIGMALINUX_API=`curl -s --header "Authorization: token $token" https://api.github.com/repos/Figma-Linux/figma-linux/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")'`
FIGMALINUX_DATAFILE="$HOME/dlfiles-data/figma-linux.txt"
if [ ! -f "$FIGMALINUX_DATAFILE" ]; then
    status "$FIGMALINUX_DATAFILE does not exist."
    status "Grabbing the latest release from GitHub."
    echo $FIGMALINUX_API > $FIGMALINUX_DATAFILE
fi
FIGMALINUX_CURRENT="$(cat ${FIGMALINUX_DATAFILE})"
if [ "$FIGMALINUX_CURRENT" != "$FIGMALINUX_API" ]; then
    status "figma-linux isn't up to date. updating now..."
    curl -s --header "Authorization: token $token" https://api.github.com/repos/Figma-Linux/figma-linux/releases/latest \
      | grep browser_download_url \
      | grep 'arm64.deb"' \
      | cut -d '"' -f 4 \
      | xargs -n 1 curl -L -o figma-linux_${FIGMALINUX_API}_arm64.deb || error "Failed to download figma-linux:arm64"

    mv figma-linux* $PKGDIR
    echo $FIGMALINUX_API > $FIGMALINUX_DATAFILE
    green "figma-linux downloaded successfully."
fi
green "figma-linux is up to date."