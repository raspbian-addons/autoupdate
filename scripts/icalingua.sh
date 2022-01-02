#!/bin/bash

# Core functions
source api
TOKENSCRIPT="/root/token.sh"
if [ ! -f $TOKENSCRIPT ]; then
    error "$TOKENSCRIPT couldn't be found. Exiting."
fi
source $TOKENSCRIPT

status "Updating icalingua."
ICALINGUIA_API=`curl -s --header "Authorization: token $token" https://api.github.com/repos/Icalingua/Icalingua/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")'`
ICALINGUA_DATAFILE="$HOME/dlfiles-data/icalingua.txt"
if [ ! -f "$ICALINGUA_DATAFILE" ]; then
    status "$ICALINGUA_DATAFILE does not exist."
    status "Grabbing the latest release from GitHub."
    echo $ICALINGUIA_API > $ICALINGUA_DATAFILE
fi
ICALINGUA_CURRENT="$(cat ${ICALINGUA_DATAFILE})"
if [ "$ICALINGUA_CURRENT" != "$ICALINGUIA_API" ]; then
    status "icalingua isn't up to date. updating now..."
    curl -s --header "Authorization: token $token" https://api.github.com/repos/Icalingua/Icalingua/releases/latest \
      | grep browser_download_url \
      | grep 'arm64.deb"' \
      | cut -d '"' -f 4 \
      | xargs -n 1 curl -L -o icalingua_${ICALINGUIA_API}_arm64.deb || error "Failed to download icalingua:arm64!"

    mv icalingua* $PKGDIR
    echo $ICALINGUIA_API > $ICALINGUA_DATAFILE
    green "icalingua downloaded successfully."
fi
green "icalingua is up to date."
