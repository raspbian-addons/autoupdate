#!/bin/bash

# Core functions
source api
TOKENSCRIPT="/root/token.sh"
if [ ! -f $TOKENSCRIPT ]; then
    error "$TOKENSCRIPT couldn't be found. Exiting."
fi
source $TOKENSCRIPT

status "Updating solaar."
SOLAAR_API=`curl -s --header "Authorization: token $token" https://api.github.com/repos/pwr-Solaar/Solaar/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")'`
SOLAAR_DATAFILE="$HOME/dlfiles-data/solaar.txt"
if [ ! -f "$SOLAAR_DATAFILE" ]; then
    status "$SOLAAR_DATAFILE does not exist."
    status "Grabbing the latest release from GitHub."
    echo $SOLAAR_API > $SOLAAR_DATAFILE
fi
SOLAAR_CURRENT="$(cat ${SOLAAR_DATAFILE})"
if [ "$SOLAAR_CURRENT" != "$SOLAAR_API" ]; then
    status "solaar isn't up to date. updating now..."
    if [ ! -f "/etc/apt/sources.list.d/solaar.list" ]; then
	      echo "solaar.list does not exist. adding repo..."
  	      echo "deb http://ppa.launchpad.net/solaar-unifying/stable/ubuntu focal main" | sudo tee /etc/apt/sources.list.d/solaar.list
	      sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 2303D595EE907473
	      sudo apt update
    fi
    echo "solaar.list exists. continuing..."
    sudo apt update
    apt download solaar:all || error "Failed to download solaar:all"
    mv solaar* $PKGDIR
    echo $SOLAAR_API > $SOLAAR_DATAFILE
    green "solaar downloaded successfully."
fi
green "solaar is up to date."
