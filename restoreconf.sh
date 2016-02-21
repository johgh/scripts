#!/bin/bash

if [[ -z $1 ]]
then
    echo 'Provide origin home'
    exit 1
fi

if [[ -z $2 ]]
then
    echo 'Provide destination home'
    exit 1
fi

ORIG_HOME=$1
DEST_HOME=$2

echo "${ORIG_HOME}"
echo "${DEST_HOME}"
exit

cd ${ORIG_HOME}/.config
cp -vRp autostart google-chrome banshee-1 calibre deluge MusicBrainz SubDownloader ${DEST_HOME}/.config
cp -vRp ${ORIG_HOME}/.local/share/rhythmbox ${DEST_HOME}/.local/share/
cp -vRp ${ORIG_HOME}/.mozilla ${DEST_HOME}/

cd ${DEST_HOME}
ln -s /media/BOOK/Torrents Torrents
ln -s /media/BOOK/Downloads Downloads
ln -s /media/BOOK/Documentos Documents

# install dotfiles and my vim setup
./setup.sh
