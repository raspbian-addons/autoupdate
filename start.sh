#!/bin/bash

# Start script for Raspbian Addons autoupdate
# This script should be run from the 'autoupdate' folder on the repo-hosting VM.

# Check for updates
echo "Checking for updates..."
localhash="$(git rev-parse HEAD)"
latesthash="$(git ls-remote https://github.com/raspbian-addons/autoupdate.git HEAD | awk '{print $1}')"
if [ "$localhash" != "$latesthash" ] && [ ! -z "$latesthash" ] && [ ! -z "$localhash" ];then
    echo "Out of date, updating now..."
    git clean -fd
    git reset --hard
    git pull https://github.com/raspbian-addons/autoupdate.git HEAD || error 'Unable to update, please check your internet connection'
else
    echo "Up to date."
fi

# Core functions
PKGDIR="/root/raspbian-addons/debian/pkgs_incoming/" # directory for incoming, unwritten packages.

function error {
  echo -e "\e[91m$1\e[39m"
  exit 1
}

function red {
  echo -e "\e[91m$1\e[39m"
}

function warning() { #yellow text
  echo -e "\e[93m\e[5m◢◣\e[25m WARNING: $1\e[0m" 1>&2
}

function status() { #cyan text to indicate what is happening
  
  #detect if a flag was passed, and if so, pass it on to the echo command
  if [[ "$1" == '-'* ]] && [ ! -z "$2" ];then
    echo -e $1 "\e[96m$2\e[0m" 1>&2
  else
    echo -e "\e[96m$1\e[0m" 1>&2
  fi
}

function green() { #announce the success of an action
  echo -e "\e[92m$1\e[0m" 1>&2
}

TOKENSCRIPT="/root/token.sh"
if [ ! -f $TOKENSCRIPT ]; then
    error "$TOKENSCRIPT couldn't be found. Exiting."
fi
source $TOKENSCRIPT

# create data directory, for storing the version.txt file
mkdir -p $HOME/dlfiles-data

# ensure armhf arch is added, needed for apt to download armhf software
sudo dpkg --add-architecture armhf

# check/download each package
for script in `ls scripts`; do
    status $script
    chmod +x scripts/$script
    bash scripts/$script || error "Execution of $script failed!"
done

status "Writing packages."
cd /root/raspbian-addons/debian
for new_pkg in `ls pkgs_incoming`; do
    status $new_pkg
    #reprepro_expect
    /root/reprepro.exp -- --noguessgpgtty -Vb /root/raspbian-addons/debian/ includedeb precise /root/raspbian-addons/debian/pkgs_incoming/$new_pkg
    if [ $? != 0 ]; then
        red "Import of $new_pkg failed!"
    else
        rm -rf pkgs_incoming/$new_pkg
    fi
done
