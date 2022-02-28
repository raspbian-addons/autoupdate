#!/bin/bash

# Core functions
source api
TOKENSCRIPT="/root/token.sh"
if [ ! -f $TOKENSCRIPT ]; then
    error "$TOKENSCRIPT couldn't be found. Exiting."
fi
source $TOKENSCRIPT

status "Updating aliyundrive-fuse."
ALIYUNDRIVEFUSE_API=`curl -s --header "Authorization: token $token" https://api.github.com/repos/messense/aliyundrive-fuse/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")'`
ALIYUNDRIVEFUSE_DATAFILE="$HOME/dlfiles-data/aliyundrive-fuse.txt"
if [ ! -f "$ALIYUNDRIVEFUSE_DATAFILE" ]; then
    status "$ALIYUNDRIVEFUSE_DATAFILE does not exist."
    status "Grabbing the latest release from GitHub."
    echo $ALIYUNDRIVEFUSE_API > $ALIYUNDRIVEFUSE_DATAFILE
fi
ALIYUNDRIVEFUSE_CURRENT="$(cat ${ALIYUNDRIVEFUSE_DATAFILE})"
if [ "$ALIYUNDRIVEFUSE_CURRENT" != "$ALIYUNDRIVEFUSE_API" ]; then
    status "aliyundrive-fuse isn't up to date. updating now..."
    curl -s --header "Authorization: token $token" https://api.github.com/repos/messense/aliyundrive-fuse/releases/latest \
      | grep browser_download_url \
      | grep 'arm64.deb"' \
      | cut -d '"' -f 4 \
      | xargs -n 1 curl -L -o aliyundrive-fuse_${ALIYUNDRIVEFUSE_API}_arm64.deb || error "Failed to download aliyundrive-fuse:arm64!"

    curl -s --header "Authorization: token $token" https://api.github.com/repos/messense/aliyundrive-fuse/releases/latest \
      | grep browser_download_url \
      | grep 'armhf.deb"' \
      | cut -d '"' -f 4 \
      | xargs -n 1 curl -L -o aliyundrive-fuse_${ALIYUNDRIVEFUSE_API}_armhf.deb || error "Failed to download aliyundrive-fuse:armhf!"

    mv aliyundrive-fuse* $PKGDIR
    echo $ALIYUNDRIVEFUSE_API > $ALIYUNDRIVEFUSE_DATAFILE
    green "aliyundrive-fuse downloaded successfully."
fi
green "aliyundrive-fuse is up to date."
