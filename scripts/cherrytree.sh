#!/bin/bash

# Core functions
source api
TOKENSCRIPT="/root/token.sh"
if [ ! -f $TOKENSCRIPT ]; then
    error "$TOKENSCRIPT couldn't be found. Exiting."
fi
source $TOKENSCRIPT

status "Updating cherrytree."
CHERRYTREE_API=`curl -s --header "Authorization: token $token" https://api.github.com/repos/PapirusDevelopmentTeam/cherrytree/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")'`
CHERRYTREE_DATAFILE="$HOME/dlfiles-data/cherrytree.txt"
if [ ! -f "$CHERRYTREE_DATAFILE" ]; then
    status "$CHERRYTREE_DATAFILE does not exist."
    status "Grabbing the latest release from GitHub."
    echo $CHERRYTREE_API > $CHERRYTREE_DATAFILE
fi
CHERRYTREE_CURRENT="$(cat ${CHERRYTREE_DATAFILE})"
if [ "$CHERRYTREE_CURRENT" != "$CHERRYTREE_API" ]; then
    status "cherrytree isn't up to date. updating now..."
    if [ ! -f "/etc/apt/sources.list.d/cherrytree.list" ]; then
	      echo "cherrytree.list does not exist. adding repo..."
  	      echo "deb http://ppa.launchpad.net/giuspen/ppa/ubuntu bionic main" | sudo tee /etc/apt/sources.list.d/cherrytree.list
	      sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys A98E8BBCABCF6A49A5DA2F43B8668B055FE1EFE4
	      sudo apt update
    fi
    echo "cherrytree.list exists. continuing..."
    sudo apt update
    apt download cherrytree:arm64 || error "Failed to download cherrytree:arm64"
    mv cherrytree* $PKGDIR
    echo $CHERRYTREE_API > $CHERRYTREE_DATAFILE
    green "cherrytree downloaded successfully."
fi
green "cherrytree is up to date."
