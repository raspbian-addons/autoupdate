#!/bin/bash

# Core functions
source api
TOKENSCRIPT="/root/token.sh"
if [ ! -f $TOKENSCRIPT ]; then
    error "$TOKENSCRIPT couldn't be found. Exiting."
fi
source $TOKENSCRIPT

status "Updating cawbird."
CAWBIRD_API=`curl -s --header "Authorization: token $token" https://api.github.com/repos/IBBoard/cawbird/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")'`
CAWBIRD_DATAFILE="$HOME/dlfiles-data/cawbird.txt"
if [ ! -f "$CAWBIRD_DATAFILE" ]; then
    status "$CAWBIRD_DATAFILE does not exist."
    status "Grabbing the latest release from GitHub."
    echo $CAWBIRD_API > $CAWBIRD_DATAFILE
fi
CAWBIRD_CURRENT="$(cat ${CAWBIRD_DATAFILE})"
if [ "$CAWBIRD_CURRENT" != "$CAWBIRD_API" ]; then
    status "cawbird isn't up to date. updating now..."
    if [ ! -f "/etc/apt/sources.list.d/cawbird.list" ]; then
	      echo "cawbird.list does not exist. adding repo..."
  	      echo 'deb http://download.opensuse.org/repositories/home:/IBBoard:/cawbird/Raspbian_10/ /' | sudo tee /etc/apt/sources.list.d/cawbird.list
          curl -fsSL https://download.opensuse.org/repositories/home:IBBoard:cawbird/Raspbian_10/Release.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/cawbird.gpg > /dev/null
	      sudo apt update
    fi
    echo "cawbird.list exists. continuing..."
    sudo apt update
    apt download cawbird:armhf || error "Failed to download cawbird:armhf"
    apt download cawbird:arm64 || error "Failed to download cawbird:arm64"
    apt download cawbird-dbg:armhf || error "Failed to download cawbird-dbg:armhf"
    apt download cawbird-dbg:arm64 || error "Failed to download cawbird-dbg:arm64"
    mv cawbird* $PKGDIR
    echo $CAWBIRD_API > $CAWBIRD_DATAFILE
    green "cawbird downloaded successfully."
fi
green "cawbird is up to date."
