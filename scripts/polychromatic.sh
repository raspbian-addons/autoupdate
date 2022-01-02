#!/bin/bash

# Core functions
source api
TOKENSCRIPT="/root/token.sh"
if [ ! -f $TOKENSCRIPT ]; then
    error "$TOKENSCRIPT couldn't be found. Exiting."
fi
source $TOKENSCRIPT

status "Updating polychromatic, polychromatic-cli, polychromatic-common, polychromatic-controller, polychromatic-tray-applet."
POLYCHROMATIC_API=`curl -s --header "Authorization: token $token" https://api.github.com/repos/polychromatic/polychromatic/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")'`
POLYCHROMATIC_DATAFILE="$HOME/dlfiles-data/polychromatic.txt"
if [ ! -f "$POLYCHROMATIC_DATAFILE" ]; then
    status "$POLYCHROMATIC_DATAFILE does not exist."
    status "Grabbing the latest release from GitHub."
    echo $POLYCHROMATIC_API > $POLYCHROMATIC_DATAFILE
fi
POLYCHROMATIC_CURRENT="$(cat ${POLYCHROMATIC_DATAFILE})"
if [ "$POLYCHROMATIC_CURRENT" != "$POLYCHROMATIC_API" ]; then
    status "polychromatic isn't up to date. updating now..."
    if [ ! -f "/etc/apt/sources.list.d/polychromatic.list" ]; then
	      echo "polychromatic.list does not exist. adding repo..."
  	    echo "deb http://ppa.launchpad.net/polychromatic/stable/ubuntu focal main" | sudo tee /etc/apt/sources.list.d/polychromatic.list
	      sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 96B9CD7C22E2C8C5
	      sudo apt update
    fi
    echo "polychromatic.list exists. continuing..."
    sudo apt update
    apt download polychromatic:all || error "Failed to download polychromatic:all"
    apt download polychromatic-cli:all || error "Failed to download polychromatic-cli:all"
    apt download polychromatic-common:all || error "Failed to download polychromatic-common:all"
    apt download polychromatic-controller:all || error "Failed to download polychromatic-controller:all"
    apt download polychromatic-tray-applet:all || error "Failed to download polychromatic-tray-applet:all"

    mv polychromatic* $PKGDIR
    echo $POLYCHROMATIC_API > $POLYCHROMATIC_DATAFILE
    green "polychromatic downloaded successfully."
fi
green "polychromatic is up to date."
