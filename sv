#!/bin/bash
input_dir=.
dest_dir=$HOME/Torrents/savedir

mkdir ${dest_dir}_0 ${dest_dir}_1 ${dest_dir}_2 ${dest_dir}_3 ${dest_dir}_4 ${dest_dir}_5 ${dest_dir}_6 ${dest_dir}_7 ${dest_dir}_8 ${dest_dir}_9 2> /dev/null

for i in $input_dir/*
do
    mplayer "$i"
    read -s -n 1 -p $'Save file?\n' option
    if [[ $option =~ ^[0-9]+$ ]]; then
        mv -v "$i" "${dest_dir}_${option}"
    fi
    if [[ $option =~ ^[eE]$ ]]; then
        exit
    fi
done
