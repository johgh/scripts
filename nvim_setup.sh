#!/bin/bash
# NOTES:
# some distros require xclip/xsel package for clipboard support
# exuberant-ctags is ctags in some distros

# this script is now cross-platform (Debian/Arch), so we don't check packages
# dependencies="exuberant-ctags wmctrl build-essential cmake python-dev php-codesniffer silversearcher-ag xsel"
# CHECK_DEPS=$HOME/bin/check_deps
# $CHECK_DEPS "$dependencies"

# install fzf
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install

# clean Vim files
cd ~
rm -Rf .vim*

# get .vim dir and install plugins
git clone --recursive https://github.com/johgh/vim .vim
ln -s ~/.vim ~/.config/nvim
nvim +PlugClean! +qall
nvim +PlugInstall +qall

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
