#!/bin/bash

# Core functions
source api
TOKENSCRIPT="/root/token.sh"
if [ ! -f $TOKENSCRIPT ]; then
    error "$TOKENSCRIPT couldn't be found. Exiting."
fi
source $TOKENSCRIPT

status "Updating spocon."
SPOCON_API=`curl -s --header "Authorization: token $token" https://api.github.com/repos/spocon/spocon/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")'`
SPOCON_DATAFILE="$HOME/dlfiles-data/spocon.txt"
if [ ! -f "$SPOCON_DATAFILE" ]; then
    status "$SPOCON_DATAFILE does not exist."
    status "Grabbing the latest release from GitHub."
    echo $SPOCON_API > $SPOCON_DATAFILE
fi
SPOCON_CURRENT="$(cat ${SPOCON_DATAFILE})"
if [ "$SPOCON_CURRENT" != "$SPOCON_API" ]; then
    status "spocon isn't up to date. updating now..."
    if [ ! -f "/etc/apt/sources.list.d/spocon.list" ]; then
	    echo "spocon.list does not exist. adding repo..."
        echo 'deb http://ppa.launchpad.net/spocon/spocon/ubuntu bionic main' | sudo tee /etc/apt/sources.list.d/spocon.list 
	    sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 7DBE8BF06EA39B78
	    sudo apt update
    fi
    echo "spocon.list exists. continuing..."
    sudo apt update
    apt download spocon:armhf || error "Failed to download spocon:armhf"
    apt download spocon:arm64 || error "Failed to download spocon:arm64"
    mv spocon* $PKGDIR
    echo $SPOCON_API > $SPOCON_DATAFILE
    green "spocon downloaded successfully."
fi
green "spocon is up to date."
