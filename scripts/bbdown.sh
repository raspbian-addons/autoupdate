#!/bin/bash

# Core functions
source api
TOKENSCRIPT="/root/token.sh"
if [ ! -f $TOKENSCRIPT ]; then
    error "$TOKENSCRIPT couldn't be found. Exiting."
fi
source $TOKENSCRIPT

status "Updating bbdown."
BBDOWN_API=`curl -s --header "Authorization: token $token" https://api.github.com/repos/nilaoda/BBDown/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")'`
BBDOWN_DATAFILE="$HOME/dlfiles-data/bbdown.txt"
if [ ! -f "$BBDOWN_DATAFILE" ]; then
    status "$BBDOWN_DATAFILE does not exist."
    status "Grabbing the latest release from GitHub."
    echo $BBDOWN_API > $BBDOWN_DATAFILE
fi
BBDOWN_CURRENT="$(cat ${BBDOWN_DATAFILE})"
if [ "$BBDOWN_CURRENT" != "$BBDOWN_API" ]; then
    status "bbdown isn't up to date. updating now..."
    BBDOWN_API_NOV=`curl -s --header "Authorization: token $token" https://api.github.com/repos/nilaoda/BBDown/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")' | tr -d 'v'`
    wget https://github.com/hmsjy2017/bbdown-debs/raw/master/bbdown_${BBDOWN_API_NOV}_arm64.deb || error "Failed to download bbdown:arm64"
    mv bbdown* $PKGDIR
    echo $BBDOWN_API > $BBDOWN_DATAFILE
    green "bbdown downloaded successfully."
fi
green "bbdown is up to date."
