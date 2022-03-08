#!/bin/bash

# Core functions
source api
TOKENSCRIPT="/root/token.sh"
if [ ! -f $TOKENSCRIPT ]; then
    error "$TOKENSCRIPT couldn't be found. Exiting."
fi
source $TOKENSCRIPT

status "Updating moonlight-qt."
MOONLIGHTQT_API=`curl -s --header "Authorization: token $token" https://api.github.com/repos/ilikenwf/moonlight-qt/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")'`
MOONLIGHTQT_DATAFILE="$HOME/dlfiles-data/moonlight-qt.txt"
if [ ! -f "$MOONLIGHTQT_DATAFILE" ]; then
    status "$MOONLIGHTQT_DATAFILE does not exist."
    status "Grabbing the latest release from GitHub."
    echo $MOONLIGHTQT_API > $MOONLIGHTQT_DATAFILE
fi
MOONLIGHTQT_CURRENT="$(cat ${MOONLIGHTQT_DATAFILE})"
if [ "$MOONLIGHTQT_CURRENT" != "$MOONLIGHTQT_API" ]; then
    status "moonlight-qt isn't up to date. updating now..."
    if [ ! -f "/etc/apt/sources.list.d/moonlight-game-streaming-moonlight-qt.list" ]; then
	      echo "moonlight-game-streaming-moonlight-qt.list does not exist. adding repo..."
  	      curl -1sLf 'https://dl.cloudsmith.io/public/moonlight-game-streaming/moonlight-qt/setup.deb.sh' | distro=raspbian codename=buster sudo -E bash
	      sudo apt update
    fi
    echo "moonlight-game-streaming-moonlight-qt.list exists. continuing..."
    sudo apt update
    apt download moonlight-qt:armhf || error "Failed to download moonlight-qt:armhf"
    apt download moonlight-qt:arm64 || error "Failed to download moonlight-qt:arm64"
    mv moonlight-qt* $PKGDIR
    echo $MOONLIGHTQT_API > $MOONLIGHTQT_DATAFILE
    green "moonlight-qt downloaded successfully."
fi
green "moonlight-qt is up to date."
