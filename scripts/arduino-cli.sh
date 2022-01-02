#!/bin/bash

# Core functions
source api
TOKENSCRIPT="/root/token.sh"
if [ ! -f $TOKENSCRIPT ]; then
    error "$TOKENSCRIPT couldn't be found. Exiting."
fi
source $TOKENSCRIPT

status "Updating arduino-cli."
ARDUINOCLI_API=`curl -s --header "Authorization: token $token" https://api.github.com/repos/arduino/arduino-cli/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")'`
ARDUINOCLI_DATAFILE="$HOME/dlfiles-data/arduino-cli.txt"
if [ ! -f "$ARDUINOCLI_DATAFILE" ]; then
    status "$ARDUINOCLI_DATAFILE does not exist."
    status "Grabbing the latest release from GitHub."
    echo $ARDUINOCLI_API > $ARDUINOCLI_DATAFILE
fi
ARDUINOCLI_CURRENT="$(cat ${ARDUINOCLI_DATAFILE})"
if [ "$ARDUINOCLI_CURRENT" != "$ARDUINOCLI_API" ]; then
    status "arduino-cli isn't up to date. updating now..."
    rm -rf arduino-cli-debbuild
    mkdir arduino-cli-debbuild
    cd arduino-cli-debbuild || error "failed to cd into arduino-cli build dir"
    mkdir 32 && cd 32
    curl -s https://api.github.com/repos/arduino/arduino-cli/releases/latest \
      | grep browser_download_url \
      | grep 'ARMv7.tar.gz"' \
      | cut -d '"' -f 4 \
      | xargs -n 1 curl -L -o arduino-cli_${ARDUINOCLI_API}_armhf.tar.gz || error "Failed to download arduino-cli v${LATEST} armhf"
    mkdir deb || error "Failed to make deb dir for deb build"
    tar -xvf arduino-cli_${ARDUINOCLI_API}_armhf.tar.gz || error "Failed to extract 32 bit archive"
    mkdir -p deb/DEBIAN
    mkdir -p deb/usr/bin
    mkdir -p deb/usr/share/doc/arduino-cli
    mv arduino-cli deb/usr/bin || error "Failed to move binary to deb/usr/bin/!"
    cd deb/usr/share/doc/arduino-cli || error "Failed to enter doc directory"
    wget https://github.com/ryanfortner/ryanfortner/releases/download/1002/arduino-cli-docs.zip || error "failed to download docs zip"
    unzip arduino-cli-docs.zip && rm arduino-cli-docs.zip || error "failed"
    cd ../../../../../
    #mv LICENSE.txt deb/usr/share/doc/arduino-cli/ || error "Failed to move license"
    echo "package (${ARDUINOCLI_API}) stable; urgency=medium
  Please check the source repo for the full changelog
  You can found the link at https://github.com/arduino/arduino-cli
-- Ryan Fortner <ryankfortner@gmail.com>  $(date -R)" > deb/DEBIAN/changelog || error "Failed to create changelog!"
    echo "Package: arduino-cli
Version: ${ARDUINOCLI_API}
Section: utils
Priority: optional
Architecture: armhf
Depends: bash
Maintainer: Ryan Fortner <ryankfortner@gmail.com>
Description: Arduino command line tool
Homepage: https://github.com/arduino/arduino-cli
Bugs: https://github.com/arduino/arduino-cli/issues" > deb/DEBIAN/control || error "Failed to create control file"
    chmod 755 deb/DEBIAN/*
    dpkg-deb --build deb/ $STARTDIR/arduino-cli_${ARDUINOCLI_API}_armhf.deb || error "Failed to build armhf deb!"
    cd ../
    mkdir 64 && cd 64
    curl -s https://api.github.com/repos/arduino/arduino-cli/releases/latest \
      | grep browser_download_url \
      | grep 'ARM64.tar.gz"' \
      | cut -d '"' -f 4 \
      | xargs -n 1 curl -L -o arduino-cli_${ARDUINOCLI_API}_arm64.tar.gz || error "Failed to download arduino-cli v${LATEST} arm64"
    mkdir deb || error "Failed to make deb dir for deb build"
    tar -xvf arduino-cli_${ARDUINOCLI_API}_arm64.tar.gz || error "Failed to extract 64 bit archive"
    mkdir -p deb/DEBIAN
    mkdir -p deb/usr/bin
    mkdir -p deb/usr/share/doc/arduino-cli
    mv arduino-cli deb/usr/bin || error "Failed to move binary to deb/usr/bin/!"
    cd deb/usr/share/doc/arduino-cli || error "Failed to enter doc directory"
    wget https://github.com/ryanfortner/ryanfortner/releases/download/1002/arduino-cli-docs.zip || error "failed to download docs zip"
    unzip arduino-cli-docs.zip && rm arduino-cli-docs.zip || error "failed"
    cd ../../../../../
    #mv LICENSE.txt deb/usr/share/doc/arduino-cli/ || error "Failed to move license"
    echo "package (${ARDUINOCLI_API}) stable; urgency=medium
  Please check the source repo for the full changelog
  You can found the link at https://github.com/arduino/arduino-cli
-- Ryan Fortner <ryankfortner@gmail.com>  $(date -R)" > deb/DEBIAN/changelog || error "Failed to create changelog!"
    echo "Package: arduino-cli
Version: ${ARDUINOCLI_API}
Section: utils
Priority: optional
Architecture: arm64
Depends: bash
Maintainer: Ryan Fortner <ryankfortner@gmail.com>
Description: Arduino command line tool
Homepage: https://github.com/arduino/arduino-cli
Bugs: https://github.com/arduino/arduino-cli/issues" > deb/DEBIAN/control || error "Failed to create control file"
    chmod 755 deb/DEBIAN/*
    dpkg-deb --build deb/ $STARTDIR/arduino-cli_${ARDUINOCLI_API}_arm64.deb || error "Failed to build arm64 deb!"
    cd $STARTDIR
    rm -rf arduino-cli-debbuild
    mv arduino-cli* $PKGDIR
    echo $ARDUINOCLI_API > $ARDUINOCLI_DATAFILE
    green "arduino-cli downloaded successfully."
fi
green "arduino-cli is up to date."
