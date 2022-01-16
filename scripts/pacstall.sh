
#!/bin/bash

# Core functions
source api
TOKENSCRIPT="/root/token.sh"
if [ ! -f $TOKENSCRIPT ]; then
    error "$TOKENSCRIPT couldn't be found. Exiting."
fi
source $TOKENSCRIPT

status "Updating pacstall."
PACSTALL_API=`curl -s --header "Authorization: token $token" https://api.github.com/repos/pacstall/pacstall/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")'`
PACSTALL_DATAFILE="$HOME/dlfiles-data/pacstall.txt"
if [ ! -f "$PACSTALL_DATAFILE" ]; then
    status "$PACSTALL_DATAFILE does not exist."
    status "Grabbing the latest release from GitHub."
    echo $PACSTALL_API > $PACSTALL_DATAFILE
fi
PACSTALL_CURRENT="$(cat ${PACSTALL_DATAFILE})"
if [ "$PACSTALL_CURRENT" != "$PACSTALL_API" ]; then
    status "howdy isn't up to date. updating now..."
    curl -s --header "Authorization: token $token" https://api.github.com/repos/pacstall/pacstall/releases/latest \
      | grep browser_download_url \
      | grep '.deb"' \
      | cut -d '"' -f 4 \
      | xargs -n 1 curl -L -o pacstall_${PACSTALL_API}_all.deb || error "Failed to download pacstall:all!"

    mv pacstall* $PKGDIR
    echo $PACSTALL_API > $PACSTALL_DATAFILE
    green "pacstall downloaded successfully."
fi
green "pacstall is up to date."
