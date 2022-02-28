#!/bin/bash

# Core functions
source api
TOKENSCRIPT="/root/token.sh"
if [ ! -f $TOKENSCRIPT ]; then
    error "$TOKENSCRIPT couldn't be found. Exiting."
fi
source $TOKENSCRIPT

status "Updating aliyundrive-fuse."
ALIYUNDRIVE-FUSE_API=`curl -s --header "Authorization: token $token" https://api.github.com/repos/messense/aliyundrive-fuse/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")'`
ALIYUNDRIVE-FUSE_DATAFILE="$HOME/dlfiles-data/aliyundrive-fuse.txt"
if [ ! -f "$ALIYUNDRIVE-FUSE_DATAFILE" ]; then
    status "$ALIYUNDRIVE-FUSE_DATAFILE does not exist."
    status "Grabbing the latest release from GitHub."
    echo $ALIYUNDRIVE-FUSE_API > $ALIYUNDRIVE-FUSE_DATAFILE
fi
ALIYUNDRIVE-FUSE_CURRENT="$(cat ${ALIYUNDRIVE-FUSE_DATAFILE})"
if [ "$ALIYUNDRIVE-FUSE_CURRENT" != "$ALIYUNDRIVE-FUSE_API" ]; then
    status "aliyundrive-fuse isn't up to date. updating now..."
    curl -s --header "Authorization: token $token" https://api.github.com/repos/messense/aliyundrive-fuse/releases/latest \
      | grep browser_download_url \
      | grep 'arm64.deb"' \
      | cut -d '"' -f 4 \
      | xargs -n 1 curl -L -o aliyundrive-fuse_${ALIYUNDRIVE-FUSE_API}_arm64.deb || error "Failed to download aliyundrive-fuse:arm64!"

    curl -s --header "Authorization: token $token" https://api.github.com/repos/messense/aliyundrive-fuse/releases/latest \
      | grep browser_download_url \
      | grep 'armhf.deb"' \
      | cut -d '"' -f 4 \
      | xargs -n 1 curl -L -o aliyundrive-fuse_${ALIYUNDRIVE-FUSE_API}_armhf.deb || error "Failed to download aliyundrive-fuse:armhf!"

    mv aliyundrive-fuse* $PKGDIR
    echo $ALIYUNDRIVE-FUSE_API > $ALIYUNDRIVE-FUSE_DATAFILE
    green "aliyundrive-fuse downloaded successfully."
fi
green "aliyundrive-fuse is up to date."
