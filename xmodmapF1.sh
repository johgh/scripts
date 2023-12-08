#!/bin/bash
# on startup and wake up /lib/systemd/system-sleep
# execute xkeycaps to get codes below (or xev to be really sure)

sleep=4

if [[ ! -z "$1" ]]; then
    sleep=$1
fi

sleep $sleep
# gsettings set org.gnome.settings-daemon.plugins.orientation active false;
xmodmap -e 'keycode 121 = F1'; # mute key
xmodmap -e 'keycode 148 = F12'; # calc key
xmodmap -e 'keycode 198 = F5'; # mic key
# xmodmap -e 'keycode 95 = minus'; # F7
# xmodmap -e 'keycode 96 = plus'; # F8

