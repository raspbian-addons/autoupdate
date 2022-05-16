#!/bin/bash

# Core functions
source api
TOKENSCRIPT="/root/token.sh"
if [ ! -f $TOKENSCRIPT ]; then
    error "$TOKENSCRIPT couldn't be found. Exiting."
fi
source $TOKENSCRIPT

status "Updating kopia."
KOPIA_API=`curl -s --header "Authorization: token $token" https://api.github.com/repos/kopia/kopia/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")' | tr -d 'v'`
KOPIA_DATAFILE="$HOME/dlfiles-data/kopia.txt"
if [ ! -f "${KOPIA_DATAFILE}" ]; then
    status "${KOPIA_DATAFILE} does not exist."
    status "Grabbing the latest release from GitHub."
    echo ${KOPIA_API} > ${KOPIA_DATAFILE}
fi
KOPIA_CURRENT="$(cat ${KOPIA_DATAFILE})"
if [ "${KOPIA_CURRENT}" != "${KOPIA_API}" ]; then
    status "kopia isn't up to date. updating now..."
    wget https://github.com/kopia/kopia/releases/download/v${KOPIA_API}/kopia_${KOPIA_API}_linux_armhf.deb -O kopia_${KOPIA_API}_armhf.deb || error "Failed to download kopia:armhf"
    wget https://github.com/kopia/kopia/releases/download/v${KOPIA_API}/kopia_${KOPIA_API}_linux_arm64.deb -O kopia_${KOPIA_API}_arm64.deb || error "Failed to download kopia:arm64"
    mv kopia* $PKGDIR
    echo ${KOPIA_API} > ${KOPIA_DATAFILE}
    green "kopia downloaded successfully."
fi
green "kopia is up to date."
