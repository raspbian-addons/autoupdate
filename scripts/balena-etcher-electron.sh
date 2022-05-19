#!/bin/bash

# Core functions
source api
TOKENSCRIPT="/root/token.sh"
if [ ! -f $TOKENSCRIPT ]; then
    error "$TOKENSCRIPT couldn't be found. Exiting."
fi
source $TOKENSCRIPT

status "Updating balena-etcher-electron."
BALENAETCHERELECTRON_API=`curl -s --header "Authorization: token $token" https://api.github.com/repos/Itai-Nelken/BalenaEtcher-arm/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")'`
BALENAETCHERELECTORN_DATAFILE="$HOME/dlfiles-data/balena-etcher-electron.txt"
if [ ! -f "$BALENAETCHERELECTORN_DATAFILE" ]; then
    status "$BALENAETCHERELECTORN_DATAFILE does not exist."
    status "Grabbing the latest release from GitHub."
    echo $BALENAETCHERELECTRON_API > $BALENAETCHERELECTORN_DATAFILE
fi
BALENAETCHERELECTRON_CURRENT="$(cat ${BALENAETCHERELECTORN_DATAFILE})"
if [ "$BALENAETCHERELECTRON_CURRENT" != "$BALENAETCHERELECTRON_API" ]; then
    status "balena-etcher-electron isn't up to date. updating now..."
    curl -s --header "Authorization: token $token" https://api.github.com/repos/Itai-Nelken/BalenaEtcher-arm/releases/latest \
      | grep browser_download_url \
      | grep 'arm64.deb"' \
      | cut -d '"' -f 4 \
      | xargs -n 1 curl -L -o balena-etcher-electron_${BALENAETCHERELECTRON_API}_arm64.deb || error "Failed to download balena-etcher-electron:arm64!"
    curl -s --header "Authorization: token $token" https://api.github.com/repos/Itai-Nelken/BalenaEtcher-arm/releases/latest \
      | grep browser_download_url \
      | grep 'armv7l.deb"' \
      | cut -d '"' -f 4 \
      | xargs -n 1 curl -L -o balena-etcher-electron_${BALENAETCHERELECTRON_API}_armhf.deb || error "Failed to download balena-etcher-electron:armhf!"

    mv balena-etcher-electron* $PKGDIR
    echo $BALENAETCHERELECTRON_API > $BALENAETCHERELECTORN_DATAFILE
    green "balena-etcher-electron downloaded successfully."
fi
green "balena-etcher-electron is up to date."
