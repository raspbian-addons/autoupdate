#!/bin/bash

# Core functions
source api
TOKENSCRIPT="/root/token.sh"
if [ ! -f $TOKENSCRIPT ]; then
    error "$TOKENSCRIPT couldn't be found. Exiting."
fi
source $TOKENSCRIPT

status "Updating foliate."
FOLIATE_API=`curl -s --header "Authorization: token $token" https://api.github.com/repos/johnfactotum/foliate/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")'`
FOLIATE_DATAFILE="$HOME/dlfiles-data/foliate.txt"
if [ ! -f "$FOLIATE_DATAFILE" ]; then
    status "$FOLIATE_DATAFILE does not exist."
    status "Grabbing the latest release from GitHub."
    echo $FOLIATE_API > $FOLIATE_DATAFILE
fi
FOLIATE_CURRENT="$(cat ${FOLIATE_DATAFILE})"
if [ "$FOLIATE_CURRENT" != "$FOLIATE_API" ]; then
    status "foliate isn't up to date. updating now..."
    curl -s --header "Authorization: token $token" https://api.github.com/repos/johnfactotum/foliate/releases/latest \
      | grep browser_download_url \
      | grep 'all.deb"' \
      | cut -d '"' -f 4 \
      | xargs -n 1 curl -L -o foliate_${FOLIATE_API}_all.deb || error "Failed to download the com.github.johnfactotum.foliate:all"

    mv foliate* $PKGDIR
    echo $FOLIATE_API > $FOLIATE_DATAFILE
    green "foliate downloaded successfully."
fi
green "foliate is up to date."