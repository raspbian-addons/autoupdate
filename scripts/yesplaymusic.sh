#!/bin/bash

# Core functions
source api
TOKENSCRIPT="/root/token.sh"
if [ ! -f $TOKENSCRIPT ]; then
    error "$TOKENSCRIPT couldn't be found. Exiting."
fi
source $TOKENSCRIPT

status "Updating yesplaymusic."
YESPLAYMUSIC_API=`curl -s --header "Authorization: token $token" https://api.github.com/repos/qier222/YesPlayMusic/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")'`
YESPLAYMUSIC_DATAFILE="$HOME/dlfiles-data/yesplaymusic.txt"
if [ ! -f "$YESPLAYMUSIC_DATAFILE" ]; then
    status "$YESPLAYMUSIC_DATAFILE does not exist."
    status "Grabbing the latest release from GitHub."
    echo $YESPLAYMUSIC_API > $YESPLAYMUSIC_DATAFILE
fi
YESPLAYMUSIC_CURRENT="$(cat ${YESPLAYMUSIC_DATAFILE})"
if [ "$YESPLAYMUSIC_CURRENT" != "$YESPLAYMUSIC_API" ]; then
    status "yesplaymusic isn't up to date. updating now..."
    curl -s --header "Authorization: token $token" https://api.github.com/repos/qier222/YesPlayMusic/releases/latest \
      | grep browser_download_url \
      | grep 'armv7l.deb"' \
      | cut -d '"' -f 4 \
      | xargs -n 1 curl -L -o yesplaymusic_${YESPLAYMUSIC_API}_armhf.deb || error "Failed to download yesplaymusic:armhf!"

    mv yesplaymusic* $PKGDIR
    echo $YESPLAYMUSIC_API > $YESPLAYMUSIC_DATAFILE
    green "yesplaymusic downloaded successfully."
fi
green "yesplaymusic is up to date."
