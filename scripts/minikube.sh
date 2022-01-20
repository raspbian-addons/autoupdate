#!/bin/bash

# Core functions
source api
TOKENSCRIPT="/root/token.sh"
if [ ! -f $TOKENSCRIPT ]; then
    error "$TOKENSCRIPT couldn't be found. Exiting."
fi
source $TOKENSCRIPT

status "Updating minikube."
MINIKUBE_API=`curl -s --header "Authorization: token $token" https://api.github.com/repos/kubernetes/minikube/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")' | tr -d 'v'`
MINIKUBE_DATAFILE="$HOME/dlfiles-data/minikube.txt"
if [ ! -f "${MINIKUBE_DATAFILE}" ]; then
    status "${MINIKUBE_DATAFILE} does not exist."
    status "Grabbing the latest release from GitHub."
    echo ${MINIKUBE_API} > ${MINIKUBE_DATAFILE}
fi
MINIKUBE_CURRENT="$(cat ${MINIKUBE_DATAFILE})"
if [ "${MINIKUBE_CURRENT}" != "${MINIKUBE_API}" ]; then
    status "minikube isn't up to date. updating now..."
    wget https://github.com/kubernetes/minikube/releases/download/v${MINIKUBE_API}/docker-machine-driver-kvm2_${MINIKUBE_API}-0_arm64.deb || error "Failed to download docker-machine-driver-kvm2:arm64"
    wget https://github.com/kubernetes/minikube/releases/download/v${MINIKUBE_API}/minikube_${MINIKUBE_API}-0_arm64.deb || error "Failed to download minikube:arm64"
    wget https://github.com/kubernetes/minikube/releases/download/v${MINIKUBE_API}/minikube_${MINIKUBE_API}-0_armhf.deb || error "Failed to download minikube:armhf!"
    mv minikube* $PKGDIR
    echo ${MINIKUBE_API} > ${MINIKUBE_DATAFILE}
    green "minikube downloaded successfully."
fi
green "minikube is up to date."
