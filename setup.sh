#!/bin/bash
dependencies="guake tmux zsh"
dotfiles=".zshrc .tmux.conf .tmux.conf.layout .vrapperrc .gitconfig .mysql.cnf .alias_functions"
autostart="guake"

# external scripts
CHECK_DEPS=$HOME/bin/check_deps
GET_GITHUB=$HOME/bin/getgithub
VIM_SETUP=$HOME/bin/vim_setup.sh

# clone/update my scripts repo
git clone https://github.com/johgh/scripts.git $HOME/bin

$CHECK_DEPS $dependencies

# clone/update conf repo and add symlinks to $HOME
$GET_GITHUB johgh/dotfiles conf

# symlink dot files to $HOME
for file in $dotfiles
do
    ln -fs $HOME/conf/$file $HOME
done

# clone/update oh-my-zsh
$GET_GITHUB robbyrussell/oh-my-zsh.git .oh-my-zsh
sudo chsh -s /bin/zsh

# add apps to startup
for app in $autostart
do
    ln -fs /usr/share/applications/${app}.desktop ~/.config/autostart/
done

# install my vim setup
$VIM_SETUP

echo 'Please reload now .zshrc: "source ~/.zshrc"'
