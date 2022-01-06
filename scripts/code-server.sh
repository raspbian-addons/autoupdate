#!/bin/bash

# Core functions
source api
TOKENSCRIPT="/root/token.sh"
if [ ! -f $TOKENSCRIPT ]; then
    error "$TOKENSCRIPT couldn't be found. Exiting."
fi
source $TOKENSCRIPT

status "Updating code-server."
CODESERVER_API=`curl -s --header "Authorization: token $token" https://api.github.com/repos/coder/code-server/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")'`
CODESERVER_DATAFILE="$HOME/dlfiles-data/code-server.txt"
if [ ! -f "$CODESERVER_DATAFILE" ]; then
    status "$CODESERVER_DATAFILE does not exist."
    status "Grabbing the latest release from GitHub."
    echo $CODESERVER_API > $CODESERVER_DATAFILE
fi
CODESERVER_CURRENT="$(cat ${CODESERVER_DATAFILE})"
if [ "$CODESERVER_CURRENT" != "$CODESERVER_API" ]; then
    status "code-server isn't up to date. updating now..."
    curl -s --header "Authorization: token $token" https://api.github.com/repos/coder/code-server/releases/latest \
      | grep browser_download_url \
      | grep 'armhf.deb"' \
      | cut -d '"' -f 4 \
      | xargs -n 1 curl -L -o code-server_${CODESERVER_API}_armhf.deb || error "Failed to download the code-server:armhf"

    curl -s --header "Authorization: token $token" https://api.github.com/repos/coder/code-server/releases/latest \
      | grep browser_download_url \
      | grep 'arm64.deb"' \
      | cut -d '"' -f 4 \
      | xargs -n 1 curl -L -o code-server_${CODESERVER_API}_arm64.deb || error "Failed to download code-server:arm64"

    mv code-server* $PKGDIR
    echo $CODESERVER_API > $CODESERVER_DATAFILE
    green "code-server downloaded successfully."
fi
green "code-server is up to date."