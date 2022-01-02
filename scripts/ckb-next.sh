#!/bin/bash

# Core functions
source api
TOKENSCRIPT="/root/token.sh"
if [ ! -f $TOKENSCRIPT ]; then
    error "$TOKENSCRIPT couldn't be found. Exiting."
fi
source $TOKENSCRIPT

status "Updating ckb-next."
CKB_API=`curl -s --header "Authorization: token $token" https://api.github.com/repos/ckb-next/ckb-next/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")'`
CKB_DATAFILE="$HOME/dlfiles-data/ckb-next.txt"
if [ ! -f "$CKB_DATAFILE" ]; then
    status "$CKB_DATAFILE does not exist."
    status "Grabbing the latest release from GitHub."
    echo $CKB_API > $CKB_DATAFILE
fi
CKB_CURRENT="$(cat ${CKB_DATAFILE})"
if [ "$CKB_CURRENT" != "$CKB_API" ]; then
    status "ckb-next isn't up to date. updating now..."
    if [ ! -f "/etc/apt/sources.list.d/ckb-next.list" ]; then
	      echo "ckb-next.list does not exist. adding repo..."
  	      echo "deb http://ppa.launchpad.net/tatokis/ckb-next/ubuntu focal main " | sudo tee /etc/apt/sources.list.d/ckb-next.list
	      sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys BA84DB44A908C515
	      sudo apt update
    fi
    echo "ckb-next.list exists. continuing..."
    sudo apt update
    apt download ckb-next:armhf || error "Failed to download ckb-next:armhf"
    #apt download ckb-next-dbgsym:armhf || error "Failed to download ckb-next-dbgsym:armhf"
    apt download ckb-next:arm64 || error "Failed to download ckb-next:arm64"
    #apt download ckb-next-dbgsym:arm64 || error "Failed to download ckb-next-dbgsym:arm64"
    mv ckb-next* $PKGDIR
    echo $CKB_API > $CKB_DATAFILE
    green "ckb-next downloaded successfully."
fi
green "ckb-next is up to date."
