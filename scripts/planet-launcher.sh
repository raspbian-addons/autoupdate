#!/bin/bash

# Core functions
source api
TOKENSCRIPT="/root/token.sh"
if [ ! -f $TOKENSCRIPT ]; then
    error "$TOKENSCRIPT couldn't be found. Exiting."
fi
source $TOKENSCRIPT

status "Updating planet-launcher."
PLANETLAUNCHER_API=`curl -s --header "Authorization: token $token" https://api.github.com/repos/mcpiscript/Planet/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")'`
PLANETLAUNCHER_DATAFILE="$HOME/dlfiles-data/planet-launcher.txt"
if [ ! -f "$PLANETLAUNCHER_DATAFILE" ]; then
    status "$PLANETLAUNCHER_DATAFILE does not exist."
    status "Grabbing the latest release from GitHub."
    echo $PLANETLAUNCHER_API > $PLANETLAUNCHER_DATAFILE
fi
PLANETLAUNCHER_CURRENT="$(cat ${PLANETLAUNCHER_DATAFILE})"
if [ "$PLANETLAUNCHER_CURRENT" != "$PLANETLAUNCHER_API" ]; then
    status "planet-launcher isn't up to date. updating now..."
    curl -s --header "Authorization: token $token" https://api.github.com/repos/mcpiscript/Planet/releases/latest \
      | grep browser_download_url \
      | grep 'all.deb"' \
      | cut -d '"' -f 4 \
      | xargs -n 1 curl -L -o planet-launcher_${PLANETLAUNCHER_API}_all.deb || error "Failed to download planet-launcher:all!"

    mv planet-launcher* $PKGDIR
    echo $PLANETLAUNCHER_API > $PLANETLAUNCHER_DATAFILE
    green "planet-launcher downloaded successfully."
fi
green "planet-launcher is up to date."
