#!/bin/bash

if [[ -z $1 ]]
then
    echo 'Provide origin home'
    exit 1
fi

ORIG_HOME=$1

cd ${ORIG_HOME}/.config
cp -vRp autostart google-chrome banshee-1 calibre deluge MusicBrainz SubDownloader ${HOME}/.config
cp -vRp ${ORIG_HOME}/.local/share/rhythmbox ${HOME}/.local/share/
cp -vRp ${ORIG_HOME}/.mozilla ${HOME}/

cd ${HOME}
ln -s /media/BOOK/Torrents Torrents
ln -s /media/BOOK/Downloads Downloads
ln -s /media/BOOK/Documentos Documents

# install dotfiles and my vim setup
${ORIG_HOME}/bin/setup.sh
