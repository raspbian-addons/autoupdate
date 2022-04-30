#!/bin/bash

# Core functions
source api
TOKENSCRIPT="/root/token.sh"
if [ ! -f $TOKENSCRIPT ]; then
    error "$TOKENSCRIPT couldn't be found. Exiting."
fi
source $TOKENSCRIPT

status "Updating retroarch."
RETROARCH_API=`curl -s --header "Authorization: token $token" https://api.github.com/repos/libretro/RetroArch/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")'`
RETROARCH_DATAFILE="$HOME/dlfiles-data/retroarch.txt"
if [ ! -f "$RETROARCH_DATAFILE" ]; then
    status "$RETROARCH_DATAFILE does not exist."
    status "Grabbing the latest release from GitHub."
    echo $RETROARCH_API > $RETROARCH_DATAFILE
fi
RETROARCH_CURRENT="$(cat ${RETROARCH_DATAFILE})"
if [ "$RETROARCH_CURRENT" != "$RETROARCH_API" ]; then
    status "retroarch isn't up to date. updating now..."
    if [ ! -f "/etc/apt/sources.list.d/retroarch.list" ]; then
	      echo "retroarch.list does not exist. adding repo..."
  	      echo "deb https://ppa.launchpadcontent.net/libretro/stable/ubuntu focal main" | sudo tee /etc/apt/sources.list.d/retroarch.list
	      sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 18DAAE7FECA3745F
	      sudo apt update
    fi
    echo "retroarch.list exists. continuing..."
    sudo apt update
    apt download retroarch:armhf || error "Failed to download retroarch:armhf"
    apt download retroarch:arm64 || error "Failed to download retroarch:arm64"
    mv retroarch* $PKGDIR
    echo $RETROARCH_API > $RETROARCH_DATAFILE
    green "retroarch downloaded successfully."
fi
green "retroarch is up to date."
