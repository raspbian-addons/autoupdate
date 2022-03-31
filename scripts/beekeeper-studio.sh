#!/bin/bash

# Core functions
source api
TOKENSCRIPT="/root/token.sh"
if [ ! -f $TOKENSCRIPT ]; then
    error "$TOKENSCRIPT couldn't be found. Exiting."
fi
source $TOKENSCRIPT

status "Updating beekeeper-studio."
BEEKEEPERSTUDIO_API=`curl -s --header "Authorization: token $token" https://api.github.com/repos/beekeeper-studio/beekeeper-studio/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")'`
BEEKEEPERSTUDIO_DATAFILE="$HOME/dlfiles-data/beekeeper-studio.txt"
if [ ! -f "$BEEKEEPERSTUDIO_DATAFILE" ]; then
    status "$BEEKEEPERSTUDIO_DATAFILE does not exist."
    status "Grabbing the latest release from GitHub."
    echo $BEEKEEPERSTUDIO_API > $BEEKEEPERSTUDIO_DATAFILE
fi
BEEKEEPERSTUDIO_CURRENT="$(cat ${BEEKEEPERSTUDIO_DATAFILE})"
if [ "$BEEKEEPERSTUDIO_CURRENT" != "$BEEKEEPERSTUDIO_API" ]; then
    status "beekeeper-studio isn't up to date. updating now..."
    curl -s --header "Authorization: token $token" https://api.github.com/repos/beekeeper-studio/beekeeper-studio/releases/latest \
      | grep browser_download_url \
      | grep 'arm64.deb"' \
      | cut -d '"' -f 4 \
      | xargs -n 1 curl -L -o beekeeper-studio_${BEEKEEPERSTUDIO_API}_arm64.deb || error "Failed to download beekeeper-studio:arm64"

    mv beekeeper-studio* $PKGDIR
    echo $BEEKEEPERSTUDIO_API > $BEEKEEPERSTUDIO_DATAFILE
    green "beekeeper-studio downloaded successfully."
fi
green "beekeeper-studio is up to date."