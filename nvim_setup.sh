#!/bin/bash
dependencies="exuberant-ctags wmctrl build-essential cmake python-dev php-codesniffer silversearcher-ag"
dists="trusty utopic vivid wily xenial yakkety"

CHECK_DEPS=$HOME/bin/check_deps

$CHECK_DEPS "$dependencies"

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

if [[ $option != 0  && $option != '' ]]
then
    # purge current Vim version (if any)
    sudo apt purge neovim

    echo "deb http://ppa.launchpad.net/neovim-ppa/unstable/ubuntu ${array[${option}]} main" | sudo tee -a  /etc/apt/sources.list

    # update and install neovim
    sudo apt update
    sudo apt install neovim
fi

# clean Vim files
cd ~
rm -Rf .vim*

# get .vim dir and install plugins
git clone --recursive https://github.com/johgh/vim .vim
nvim +PlugInstall +qall

# if [ -f $HOME/.vim/bundle/YouCompleteMe/install.sh ]
# then
#     $HOME/.vim/bundle/YouCompleteMe/install.sh
# fi

# if [ ! -d $HOME/fonts ]
# then
#     git clone https://github.com/powerline/fonts
#     $HOME/fonts/install
# fi

cp -R $HOME/.vim/fonts/* $HOME/.local/share/fonts
fc-cache -f $HOME/.local/share/fonts

# configuring PSR (codesniffer)
content="<?php
$phpCodeSnifferConfig = array (
        'default_standard' => 'PSR2',
        )
?>"
echo "$content" | sudo tee /etc/php-codesniffer/CodeSniffer.conf > /dev/null

# symlink .vimrc to $HOME
ln -fs $HOME/.vim/vimrc $HOME/.vimrc
# symlink .vim to neovim dir
ln -s ~/.vim ~/.config/nvim
ln -s ~/.vimrc ~/.config/nvim/init.vim
