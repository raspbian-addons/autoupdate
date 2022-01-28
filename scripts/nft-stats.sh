#!/bin/bash

# Core functions
source api
TOKENSCRIPT="/root/token.sh"
if [ ! -f $TOKENSCRIPT ]; then
    error "$TOKENSCRIPT couldn't be found. Exiting."
fi
source $TOKENSCRIPT

status "Updating nft-stats."
NFTSTATS_API=`curl -s --header "Authorization: token $token" https://api.github.com/repos/azlux/nft-stats/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")' | tr -d 'v'`
NFTSTATS_DATAFILE="$HOME/dlfiles-data/nft-stats.txt"
if [ ! -f "$NFTSTATS_DATAFILE" ]; then
    status "$NFTSTATS_DATAFILE does not exist."
    status "Grabbing the latest release from GitHub."
    echo $NFTSTATS_API > $NFTSTATS_DATAFILE
fi
NFTSTATS_CURRENT="$(cat ${NFTSTATS_DATAFILE})"
if [ "$NFTSTATS_CURRENT" != "$NFTSTATS_API" ]; then
    status "nft-stats isn't up to date. updating now..."
    wget https://packages.azlux.fr/debian/pool/main/n/nft-stats/nft-stats_${NFTSTATS_API}_all.deb -O nft-stats_${NFTSTATS_API}_all.deb || error "Failed to download nft-stats:armhf!"
    mv nft-stats* $PKGDIR
    echo $NFTSTATS_API > $NFTSTATS_DATAFILE
    green "nft-stats downloaded successfully."
fi
green "nft-stats is up to date."
