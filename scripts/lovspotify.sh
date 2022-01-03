#!/bin/bash

# Core functions
source api
TOKENSCRIPT="/root/token.sh"
if [ ! -f $TOKENSCRIPT ]; then
    error "$TOKENSCRIPT couldn't be found. Exiting."
fi
source $TOKENSCRIPT

status "Updating lovspotify."
LOVSPOTIFY_API=`curl -s --header "Authorization: token $token" https://api.github.com/repos/spocon/lovspotify/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")'`
LOVSPOTIFY_DATAFILE="$HOME/dlfiles-data/lovspotify.txt"
if [ ! -f "$LOVSPOTIFY_DATAFILE" ]; then
    status "$LOVSPOTIFY_DATAFILE does not exist."
    status "Grabbing the latest release from GitHub."
    echo $LOVSPOTIFY_API > $LOVSPOTIFY_DATAFILE
fi
LOVSPOTIFY_CURRENT="$(cat ${LOVSPOTIFY_DATAFILE})"
if [ "$LOVSPOTIFY_CURRENT" != "$LOVSPOTIFY_API" ]; then
    status "lovspotify isn't up to date. updating now..."
    if [ ! -f "/etc/apt/sources.list.d/lovspotify.list" ]; then
	      echo "spocon.list does not exist. adding repo..."
  	      echo 'deb http://ppa.launchpad.net/spocon/lovspotify/ubuntu bionic main' | sudo tee /etc/apt/sources.list.d/lovspotify.list
	      sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 7DBE8BF06EA39B78
	      sudo apt update
    fi
    echo "lovspotify.list exists. continuing..."
    sudo apt update
    apt download lovspotify:armhf || error "Failed to download lovspotify:armhf"
    apt download lovspotify:arm64 || error "Failed to download lovspotify:arm64"

    mv lovspotify* $PKGDIR
    echo $LOVSPOTIFY_API > $LOVSPOTIFY_DATAFILE
    green "lovspotify downloaded successfully."
fi
green "lovspotify is up to date."
