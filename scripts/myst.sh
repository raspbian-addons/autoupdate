#!/bin/bash

# Core functions
source api
TOKENSCRIPT="/root/token.sh"
if [ ! -f $TOKENSCRIPT ]; then
    error "$TOKENSCRIPT couldn't be found. Exiting."
fi
source $TOKENSCRIPT

status "Updating myst."
MYST_API=`curl -s --header "Authorization: token $token" https://api.github.com/repos/mysteriumnetwork/node/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")'`
MYST_DATAFILE="$HOME/dlfiles-data/myst.txt"
if [ ! -f "$MYST_DATAFILE" ]; then
    status "$MYST_DATAFILE does not exist."
    status "Grabbing the latest release from GitHub."
    echo $MYST_API > $MYST_DATAFILE
fi
MYST_CURRENT="$(cat ${MYST_DATAFILE})"
if [ "$MYST_CURRENT" != "$MYST_API" ]; then
    status "myst isn't up to date. updating now..."
    if [ ! -f "/etc/apt/sources.list.d/myst.list" ]; then
	      echo "myst.list does not exist. adding repo..."
  	      echo "deb https://ppa.launchpadcontent.net/mysteriumnetwork/node/ubuntu focal main" | sudo tee /etc/apt/sources.list.d/myst.list
	      sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys ECCB6A56B22C536D
	      sudo apt update
    fi
    echo "myst.list exists. continuing..."
    sudo apt update
    apt download myst:armhf || error "Failed to download myst:armhf!"
    apt download myst:arm64 || error "Failed to download myst:arm64!"
    mv myst* $PKGDIR
    echo $MYST_API > $MYST_DATAFILE
    green "myst downloaded successfully."
fi
green "myst is up to date."

