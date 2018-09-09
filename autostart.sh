#!/bin/bash

# dependencies: wmctrl

# autostart this script (gnome/xfce):
# ln -s ~/bin/autostart.sh ~/.config/autostart/

# shell extension auto move windows (only gnome 3):
# gsettings set org.gnome.shell.extensions.auto-move-windows application-list "['banshee-media-player.desktop:2', 'deluge.desktop:2', 'rhythmbox.desktop:2', 'google-chrome.desktop:1', 'firefox.desktop:1']"

# tilix startup: just create shortcut 'tilix --quake --full-screen --session="~/dotfiles/tilix.json"'


### START APPS ###
# chromium &
# google-chrome &
# lollypop &
env BAMF_DESKTOP_FILE_HINT=/var/lib/snapd/desktop/applications/wavebox_wavebox.desktop /var/lib/snapd/snap/bin/wavebox %U &
# wavebox &
wait # wait for all background jobs before continuing


### APPS ID ###
wavebox=`wmctrl -l | grep Wavebox | cut -d ' ' -f1`
# lollypop=`wmctrl -l | grep Lollypop | cut -d ' ' -f1`
# chrome=`wmctrl -l | grep -E 'Chromium|Chrome' | cut -d ' ' -f1`


### MOVE TO DESKTOP 0 ###
# wmctrl -i -r $chrome -t 1 2> /dev/null


### MOVE TO DESKTOP 1 ###
wmctrl -i -r $wavebox -t 1 2> /dev/null
# wmctrl -i -r $lollypop -t 1 2> /dev/null

