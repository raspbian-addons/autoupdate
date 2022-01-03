#!/bin/bash

# Core functions
source api
TOKENSCRIPT="/root/token.sh"
if [ ! -f $TOKENSCRIPT ]; then
    error "$TOKENSCRIPT couldn't be found. Exiting."
fi
source $TOKENSCRIPT

status "Updating papirus-icon-theme."
PICONTHEME_API=`curl -s --header "Authorization: token $token" https://api.github.com/repos/spocon/papirus-icon-theme/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")'`
PICONTHEME_DATAFILE="$HOME/dlfiles-data/papirus-icon-theme.txt"
if [ ! -f "$PICONTHEME_DATAFILE" ]; then
    status "$PICONTHEME_DATAFILE does not exist."
    status "Grabbing the latest release from GitHub."
    echo $PICONTHEME_API > $PICONTHEME_DATAFILE
fi
PICONTHEME_CURRENT="$(cat ${PICONTHEME_DATAFILE})"
if [ "$PICONTHEME_CURRENT" != "$PICONTHEME_API" ]; then
    status "papirus-icon-theme isn't up to date. updating now..."
    if [ ! -f "/etc/apt/sources.list.d/papirus-icon-theme.list" ]; then
	      echo "papirus-icon-theme.list does not exist. adding repo..."
  	      echo "deb http://ppa.launchpad.net/papirus/papirus/ubuntu bionic main" | sudo tee /etc/apt/sources.list.d/papirus-icon-theme.list
	      sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 9461999446FAF0DF770BFC9AE58A9D36647CAE7F
	      sudo apt update
    fi
    echo "papirus-icon-theme.list exists. continuing..."
    sudo apt update
    apt download papirus-icon-theme:all || error "Failed to download papirus-icon-theme:all"
    mv papirus-icon-theme* $PKGDIR
    echo $PICONTHEME_API > $PICONTHEME_DATAFILE
    green "papirus-icon-theme downloaded successfully."
fi
green "papirus-icon-theme is up to date."
