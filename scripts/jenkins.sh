#!/bin/bash

# Core functions
source api
TOKENSCRIPT="/root/token.sh"
if [ ! -f $TOKENSCRIPT ]; then
    error "$TOKENSCRIPT couldn't be found. Exiting."
fi
source $TOKENSCRIPT

status "Updating jenkins."
JENKINS_API=`curl -s --header "Authorization: token $token" https://api.github.com/repos/jenkinsci/jenkins/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")'`
JENKINS_DATAFILE="$HOME/dlfiles-data/jenkins.txt"
if [ ! -f "$JENKINS_DATAFILE" ]; then
    status "$JENKINS_DATAFILE does not exist."
    status "Grabbing the latest release from GitHub."
    echo $JENKINS_API > $JENKINS_DATAFILE
fi
JENKINS_CURRENT="$(cat ${JENKINS_DATAFILE})"
if [ "$JENKINS_CURRENT" != "$JENKINS_API" ]; then
    status "jenkins isn't up to date. updating now..."
    if [ ! -f "/etc/apt/sources.list.d/jenkins.list" ]; then
	      echo "jenkins.list does not exist. adding repo..."
  	      sudo bash -c "echo 'deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian binary/' > /etc/apt/sources.list.d/jenkins.list"
	      curl -fsSL https://pkg.jenkins.io/debian/jenkins.io.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
	      sudo apt update
    fi
    echo "jenkins.list exists. continuing..."
    sudo apt update
    apt download jenkins:all || error "Failed to download jenkins:all"
    mv jenkins* $PKGDIR
    echo $JENKINS_API > $JENKINS_DATAFILE
    green "jenkins downloaded successfully."
fi
green "jenkins is up to date."
