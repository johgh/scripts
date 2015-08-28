#!/bin/bash
dependencies="wmctrl build-essential cmake python-dev php-codesniffer silversearcher-ag"
dists="devel lucid maverick natty oneiric precise quantal raring saucy trusty utopic vivid wily"

CHECK_DEPS=$HOME/bin/check_deps

$CHECK_DEPS $dependencies

if [[ -f ~/.vimrc || -d ~/.vim ]]
then
    read -n 1 -s -p $'Previous installation detected. Do you want to continue overwriting previous installation? [y/N]\n' option
    if [ $option != 'y' ]
    then
        echo 'Installation canceled by user'
        exit 1
    fi
fi

i=0
array[0]="Don't install Vim (install only .vim directory)"
echo "[$i] $array"
for distro in $dists
do
    (( i ++ ))
    echo "[$i] $distro"
    array[$i]="$distro"
done

read -s -n 1 -p $'Select your distro for installing Vim:\n' option

if [[ $option != 0 ]]
then
    # purge current Vim version (if any)
    sudo apt-get purge vim-*

    echo "deb http://ppa.launchpad.net/pi-rho/dev/ubuntu ${array[${option}]} main" | sudo tee -a  /etc/apt/sources.list
    # ALT REPO
    # echo "deb http://ppa.launchpad.net/pkg-vim/vim-daily/ubuntu ${array[${option}]} main" | sudo tee -a /etc/apt/sources.list

    # update and install gvim
    sudo apt-get update && sudo apt-get install vim vim-gnome
fi

# clean Vim files
cd ~
rm -Rf .vim*

# get .vim dir with submodules
git clone --recursive https://github.com/johgh/vim .vim
$HOME/.vim/bundle/YouCompleteMe/install.sh

if [ ! -d $HOME/fonts ]
then
    git clone https://github.com/powerline/fonts
    $HOME/fonts/install
fi

# configuring PSR (codesniffer)
content="<?php
$phpCodeSnifferConfig = array (
        'default_standard' => 'PSR2',
        )
?>"
echo "$content" | sudo tee /etc/php-codesniffer/CodeSniffer.conf > /dev/null

# symlink .vimrc to $HOME
ln -fs $HOME/.vim/.vimrc .
