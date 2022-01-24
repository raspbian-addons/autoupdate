#!/bin/bash

# Core functions
source api
TOKENSCRIPT="/root/token.sh"
if [ ! -f $TOKENSCRIPT ]; then
    error "$TOKENSCRIPT couldn't be found. Exiting."
fi
source $TOKENSCRIPT

status "Updating xmake."
XMAKE_API=`curl -s --header "Authorization: token $token" https://api.github.com/repos/xmake-io/xmake/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")'`
XMAKE_DATAFILE="$HOME/dlfiles-data/xmake.txt"
if [ ! -f "$XMAKE_DATAFILE" ]; then
    status "$XMAKE_DATAFILE does not exist."
    status "Grabbing the latest release from GitHub."
    echo $XMAKE_API > $XMAKE_DATAFILE
fi
XMAKE_CURRENT="$(cat ${XMAKE_DATAFILE})"
if [ "$XMAKE_CURRENT" != "$XMAKE_API" ]; then
    status "xmake isn't up to date. updating now..."
    XMAKE_API_NOV=`curl -s --header "Authorization: token $token" https://api.github.com/repos/xmake-io/xmake/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")' | tr -d 'v'`
    wget https://github.com/hmsjy2017/xmake-debs/raw/main/xmake_${XMAKE_API_NOV}_arm64.deb || error "Failed to download xmake:arm64"
    wget https://github.com/hmsjy2017/xmake-debs/raw/main/xmake_${XMAKE_API_NOV}_armhf.deb || error "Failed to download xmake:armhf"
    mv xmake* $PKGDIR
    echo $XMAKE_API > $XMAKE_DATAFILE
    green "xmake downloaded successfully."
fi
green "xmake is up to date."
