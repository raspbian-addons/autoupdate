#!/bin/bash

# Core functions
source api
TOKENSCRIPT="/root/token.sh"
if [ ! -f $TOKENSCRIPT ]; then
    error "$TOKENSCRIPT couldn't be found. Exiting."
fi
source $TOKENSCRIPT

status "Updating kopia-ui."
KOPIAUI_API=`curl -s --header "Authorization: token $token" https://api.github.com/repos/kopia/kopia/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")' | tr -d 'v'`
KOPIAUI_DATAFILE="$HOME/dlfiles-data/kopia-ui.txt"
if [ ! -f "${KOPIAUI_DATAFILE}" ]; then
    status "${KOPIAUI_DATAFILE} does not exist."
    status "Grabbing the latest release from GitHub."
    echo ${KOPIAUI_API} > ${KOPIAUI_DATAFILE}
fi
KOPIAUI_CURRENT="$(cat ${KOPIAUI_DATAFILE})"
if [ "${KOPIAUI_CURRENT}" != "${KOPIAUI_API}" ]; then
    status "kopia-ui isn't up to date. updating now..."
    wget https://github.com/kopia/kopia/releases/download/v${KOPIAUI_API}/kopia-ui_${KOPIAUI_API}_armv7l.deb -O kopia-ui_${KOPIAUI_API}_armhf.deb || error "Failed to download kopia-ui:armhf"
    wget https://github.com/kopia/kopia/releases/download/v${KOPIAUI_API}/kopia-ui_${KOPIAUI_API}_arm64.deb -O kopia-ui_${KOPIAUI_API}_arm64.deb || error "Failed to download kopia-ui:arm64"
    mv kopia-ui* $PKGDIR
    echo ${KOPIAUI_API} > ${KOPIAUI_DATAFILE}
    green "kopia-ui downloaded successfully."
fi
green "kopia-ui is up to date."
