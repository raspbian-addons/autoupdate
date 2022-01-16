#!/bin/bash

# Core functions
source api
TOKENSCRIPT="/root/token.sh"
if [ ! -f $TOKENSCRIPT ]; then
    error "$TOKENSCRIPT couldn't be found. Exiting."
fi
source $TOKENSCRIPT

status "Updating turbowarp-desktop."
TURBOWARP_API=`curl -s --header "Authorization: token $token" https://api.github.com/repos/TurboWarp/desktop/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")' | tr -d 'v'`
TURBOWARP_DATAFILE="$HOME/dlfiles-data/turbowarp-desktop.txt"
if [ ! -f "${TURBOWARP_DATAFILE}" ]; then
    status "${TURBOWARP_DATAFILE} does not exist."
    status "Grabbing the latest release from GitHub."
    echo ${TURBOWARP_API} > ${TURBOWARP_DATAFILE}
fi
TURBOWARP_CURRENT="$(cat ${TURBOWARP_DATAFILE})"
if [ "${TURBOWARP_CURRENT}" != "${TURBOWARP_API}" ]; then
    status "turbowarp-desktop isn't up to date. updating now..."
    wget https://github.com/TurboWarp/desktop/releases/download/v${TURBOWARP_API}/TurboWarp-linux-arm64-${TURBOWARP_API}.deb -O turbowarp-desktop_${TURBOWARP_API}_arm64.deb || error "Failed to download turbowarp-desktop:arm64"
    wget https://github.com/TurboWarp/desktop/releases/download/v${TURBOWARP_API}/TurboWarp-linux-armv7l-${TURBOWARP_API}.deb -O turbowarp-desktop_${TURBOWARP_API}_armhf.deb || error "Failed to download turbowarp-desktop:armhf"
    mv turbowarp-desktop* $PKGDIR
    echo ${TURBOWARP_API} > ${TURBOWARP_DATAFILE}
    green "turbowarp-desktop downloaded successfully."
fi
green "turbowarp-desktop is up to date."
