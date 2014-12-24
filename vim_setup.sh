#!/bin/bash
if [ ! -z $1 ]
then
    # purge current vim version (if any)
    sudo apt-get purge vim-*

    # echo "deb http://ppa.launchpad.net/pkg-vim/vim-daily/ubuntu $1 main" | sudo tee -a /etc/apt/sources.list
    echo "deb http://ppa.launchpad.net/pi-rho/dev/ubuntu $1 main" | sudo tee -a  /etc/apt/sources.list

    # update and install gvim
    sudo apt-get update && sudo apt-get install vim vim-gnome
fi

# clean vim files
cd ~
rm -Rf .vim .vimrc .viminfo .vimbackup .vimswap .vimundo .vimviews

# get .vim dir and submodules
git clone --recursive https://github.com/johgh/vim .vim
$HOME/.vim/bundle/YouCompleteMe/install.sh

if [ ! -d $HOME/fonts ]
    git clone https://github.com/powerline/fonts
    $HOME/fonts/install
fi

# symlink .vimrc to $HOME
ln -fs $HOME/.vim/.vimrc .
