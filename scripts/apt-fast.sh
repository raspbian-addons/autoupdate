#!/bin/bash

# Core functions
source api
TOKENSCRIPT="/root/token.sh"
if [ ! -f $TOKENSCRIPT ]; then
    error "$TOKENSCRIPT couldn't be found. Exiting."
fi
source $TOKENSCRIPT

status "Updating apt-fast."
APTFAST_API=`curl -s --header "Authorization: token $token" https://api.github.com/repos/ilikenwf/apt-fast/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")'`
APTFAST_DATAFILE="$HOME/dlfiles-data/apt-fast.txt"
if [ ! -f "$APTFAST_DATAFILE" ]; then
    status "$APTFAST_DATAFILE does not exist."
    status "Grabbing the latest release from GitHub."
    echo $APTFAST_API > $APTFAST_DATAFILE
fi
APTFAST_CURRENT="$(cat ${APTFAST_DATAFILE})"
if [ "$APTFAST_CURRENT" != "$APTFAST_API" ]; then
    status "apt-fast isn't up to date. updating now..."
    if [ ! -f "/etc/apt/sources.list.d/apt-fast.list" ]; then
	      echo "apt-fast.list does not exist. adding repo..."
  	      echo "deb https://ppa.launchpadcontent.net/apt-fast/stable/ubuntu focal main" | sudo tee /etc/apt/sources.list.d/apt-fast.list
	      sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys A2166B8DE8BDC3367D1901C11EE2FF37CA8DA16B
	      sudo apt update
    fi
    echo "apt-fast.list exists. continuing..."
    sudo apt update
    apt download apt-fast:all || error "Failed to download apt-fast:all"
    mv apt-fast* $PKGDIR
    echo $APTFAST_API > $APTFAST_DATAFILE
    green "apt-fast downloaded successfully."
fi
green "apt-fast is up to date."
