#!/bin/bash

# Core functions
source api
TOKENSCRIPT="/root/token.sh"
if [ ! -f $TOKENSCRIPT ]; then
    error "$TOKENSCRIPT couldn't be found. Exiting."
fi
source $TOKENSCRIPT

status "Updating monero-gui."
MONEROGUI_API=`curl -s --header "Authorization: token $token" https://api.github.com/repos/monero-project/monero-gui/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")'`
MONEROGUI_DATAFILE="$HOME/dlfiles-data/monero-gui.txt"
if [ ! -f "$MONEROGUI_DATAFILE" ]; then
    status "$MONEROGUI_DATAFILE does not exist."
    status "Grabbing the latest release from GitHub."
    echo $MONEROGUI_API > $MONEROGUI_DATAFILE
fi
MONEROGUI_CURRENT="$(cat ${MONEROGUI_DATAFILE})"
if [ "$MONEROGUI_CURRENT" != "$MONEROGUI_API" ]; then
    status "monero-gui isn't up to date. updating now..."
    if [ ! -f "/etc/apt/sources.list.d/monero-gui.list" ]; then
	      echo "monero-gui.list does not exist. adding repo..."
  	      wget https://www.whonix.org/derivative.asc -O /usr/share/keyrings/derivative.asc
          echo "deb [signed-by=/usr/share/keyrings/derivative.asc] https://deb.whonix.org bullseye main contrib non-free" | sudo tee /etc/apt/sources.list.d/derivative.list
          sudo apt-get update
    fi
    echo "monero-gui.list exists. continuing..."
    sudo apt update
    apt download monero-gui:all || error "Failed to download monero-gui:all"
    mv monero-gui* $PKGDIR
    echo $MONEROGUI_API > $MONEROGUI_DATAFILE
    green "monero-gui downloaded successfully."
fi
green "monero-gui is up to date."
