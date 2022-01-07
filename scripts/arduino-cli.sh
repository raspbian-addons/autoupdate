#!/bin/bash

# Core functions
source api
TOKENSCRIPT="/root/token.sh"
if [ ! -f $TOKENSCRIPT ]; then
    error "$TOKENSCRIPT couldn't be found. Exiting."
fi
source $TOKENSCRIPT

status "Updating arduino-cli."
ARDUINOCLI_API=`curl -s --header "Authorization: token $token" https://api.github.com/repos/arduino/arduino-cli/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")' | tr -d 'v'`
ARDUINOCLI_DATAFILE="$HOME/dlfiles-data/arduino-cli.txt"
if [ ! -f "$ARDUINOCLI_DATAFILE" ]; then
    status "$ARDUINOCLI_DATAFILE does not exist."
    status "Grabbing the latest release from GitHub."
    echo $ARDUINOCLI_API > $ARDUINOCLI_DATAFILE
fi
ARDUINOCLI_CURRENT="$(cat ${ARDUINOCLI_DATAFILE})"
if [ "$ARDUINOCLI_CURRENT" != "$ARDUINOCLI_API" ]; then
    status "arduino-cli isn't up to date. updating now..."
    wget https://github.com/ryanfortner/arduino-cli-arm/raw/master/arduino-cli_${ARDUINOCLI_API}_arm64.deb || error "Failed to download arduino-cli:arm64"
    wget https://github.com/ryanfortner/arduino-cli-arm/raw/master/arduino-cli_${ARDUINOCLI_API}_armhf.deb || error "Failed to download arduino-cli:armhf"
    mv arduino-cli* $PKGDIR
    echo $ARDUINOCLI_API > $ARDUINOCLI_DATAFILE
    green "arduino-cli downloaded successfully."
fi
green "arduino-cli is up to date."
