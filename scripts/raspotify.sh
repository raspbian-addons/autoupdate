#!/bin/bash

# Core functions
source api
TOKENSCRIPT="/root/token.sh"
if [ ! -f $TOKENSCRIPT ]; then
    error "$TOKENSCRIPT couldn't be found. Exiting."
fi
source $TOKENSCRIPT

status "Updating raspotify."
RASPOTIFY_API=`curl -s --header "Authorization: token $token" https://api.github.com/repos/dtcooper/raspotify/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")'`
RASPOTIFY_DATAFILE="$HOME/dlfiles-data/raspotify.txt"
if [ ! -f "$RASPOTIFY_DATAFILE" ]; then
    status "$RASPOTIFY_DATAFILE does not exist."
    status "Grabbing the latest release from GitHub."
    echo $RASPOTIFY_API > $RASPOTIFY_DATAFILE
fi
RASPOTIFY_CURRENT="$(cat ${RASPOTIFY_DATAFILE})"
if [ "$RASPOTIFY_CURRENT" != "$RASPOTIFY_API" ]; then
    status "raspotify isn't up to date. updating now..."
    if [ ! -f "/etc/apt/sources.list.d/raspotify.list" ]; then
	    curl -sSL https://dtcooper.github.io/raspotify/key.asc | sudo tee /usr/share/keyrings/raspotify_key.asc  > /dev/null
        sudo chmod 644 /usr/share/keyrings/raspotify_key.asc
	    echo "deb [signed-by=/usr/share/keyrings/raspotify_key.asc] https://dtcooper.github.io/raspotify raspotify main" | sudo tee /etc/apt/sources.list.d/raspotify.list
    fi
    echo "raspotify.list exists. continuing..."
    sudo apt update
    apt download raspotify:armhf || error "Failed to download raspotify:armhf"
    mv raspotify* $PKGDIR
    echo $RASPOTIFY_API > $RASPOTIFY_DATAFILE
    green "raspotify downloaded successfully."
fi
green "raspotify is up to date."
