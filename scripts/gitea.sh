#!/bin/bash

# Core functions
source api
TOKENSCRIPT="/root/token.sh"
if [ ! -f $TOKENSCRIPT ]; then
    error "$TOKENSCRIPT couldn't be found. Exiting."
fi
source $TOKENSCRIPT

status "Updating gitea."
GITEA_API=`curl -s --header "Authorization: token $token" https://api.github.com/repos/go-gitea/gitea/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")'`
GITEA_DATAFILE="$HOME/dlfiles-data/gitea.txt"
if [ ! -f "$GITEA_DATAFILE" ]; then
    status "$GITEA_DATAFILE does not exist."
    status "Grabbing the latest release from GitHub."
    echo $GITEA_API > $GITEA_DATAFILE
fi
GITEA_CURRENT="$(cat ${GITEA_DATAFILE})"
if [ "$GITEA_CURRENT" != "$GITEA_API" ]; then
    status "gitea isn't up to date. updating now..."
    GITEA_API_NOV=`curl -s --header "Authorization: token $token" https://api.github.com/repos/go-gitea/gitea/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")' | tr -d 'v'`
    wget https://github.com/ryanfortner/gitea-arm/raw/master/gitea_${GITEA_API_NOV}_arm64.deb || error "Failed to download gitea:arm64"
    wget https://github.com/ryanfortner/gitea-arm/raw/master/gitea_${GITEA_API_NOV}_armhf.deb || error "Failed to download gitea:armhf"
    mv gitea* $PKGDIR
    echo $GITEA_API > $GITEA_DATAFILE
    green "gitea downloaded successfully."
fi
green "gitea is up to date."
