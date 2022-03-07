#!/bin/bash

# Core functions
source api
TOKENSCRIPT="/root/token.sh"
if [ ! -f $TOKENSCRIPT ]; then
    error "$TOKENSCRIPT couldn't be found. Exiting."
fi
source $TOKENSCRIPT

status "Updating system-monitoring-center."
SMC_API=`curl -s --header "Authorization: token $token" https://api.github.com/repos/hakandundar34coding/system-monitoring-center/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")'`
SMC_DATAFILE="$HOME/dlfiles-data/system-monitoring-center.txt"
if [ ! -f "$SMC_DATAFILE" ]; then
    status "$SMC_DATAFILE does not exist."
    status "Grabbing the latest release from GitHub."
    echo $SMC_API > $SMC_DATAFILE
fi
SMC_CURRENT="$(cat ${SMC_DATAFILE})"
if [ "$SMC_CURRENT" != "$SMC_API" ]; then
    status "system-monitoring-center isn't up to date. updating now..."
    curl -s --header "Authorization: token $token" https://api.github.com/repos/hakandundar34coding/system-monitoring-center/releases/latest \
      | grep browser_download_url \
      | grep 'all.deb"' \
      | cut -d '"' -f 4 \
      | xargs -n 1 curl -L -o system-monitoring-center_${SMC_API}_all.deb || error "Failed to download system-monitoring-center:all!"

    mv system-monitoring-center* $PKGDIR
    echo $SMC_API > $SMC_DATAFILE
    green "system-monitoring-center downloaded successfully."
fi
green "system-monitoring-center is up to date."
