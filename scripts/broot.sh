#!/bin/bash

# Core functions
source api
TOKENSCRIPT="/root/token.sh"
if [ ! -f $TOKENSCRIPT ]; then
    error "$TOKENSCRIPT couldn't be found. Exiting."
fi
source $TOKENSCRIPT

status "Updating broot."
BROOT_API=`curl -s --header "Authorization: token $token" https://api.github.com/repos/Canop/broot/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")' | tr -d 'v'`
BROOT_DATAFILE="$HOME/dlfiles-data/broot.txt"
if [ ! -f "$BROOT_DATAFILE" ]; then
    status "$BROOT_DATAFILE does not exist."
    status "Grabbing the latest release from GitHub."
    echo $BROOT_API > $BROOT_DATAFILE
fi
BROOT_CURRENT="$(cat ${BROOT_DATAFILE})"
if [ "$BROOT_CURRENT" != "$BROOT_API" ]; then
    status "broot isn't up to date. updating now..."
    mkdir broot-tmp || error "Failed to make broot build dir."
    cd broot-tmp || error "Failed to enter broot build dir."
    mkdir deb-base || error "Failed to make deb base folder for broot."
    mkdir -p deb-base/DEBIAN && mkdir -p deb-base/usr/bin
    wget https://dystroy.org/broot/download/armv7-unknown-linux-gnueabihf/broot -O deb-base/usr/bin/broot || error "Failed to download broot binary"
    chmod +x deb-base/usr/bin/broot || error "Failed to make broot binary executable"
    echo "Package: broot
Version: ${BROOT_API}
Section: net
Priority: optional
Architecture: armhf
Depends: bash
Maintainer: Ryan Fortner <ryankfortner@gmail.com>
Description: A new way to see and navigate directory trees
Homepage: https://dystroy.org/broot/
Bugs: https://github.com/Canop/broot/issues" > deb-base/DEBIAN/control || error "Failed to make control file for broot"
    chmod 755 deb-base/DEBIAN/*
    chmod 755 deb-base/DEBIAN
    dpkg-deb --build deb-base/ ../broot_${BROOT_API}_armhf.deb || error "failed to create broot deb file (armhf)!"
    cd ../ && rm -rf broot-tmp
    #wget https://packages.azlux.fr/debian/pool/main/b/broot/broot_${BROOT_API}_armhf.deb -O broot_${BROOT_API}_armhf.deb || error "Failed to download broot:armhf!"
    mv broot* $PKGDIR
    echo $BROOT_API > $BROOT_DATAFILE
    green "broot downloaded successfully."
fi
green "broot is up to date."
