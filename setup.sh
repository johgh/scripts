#!/bin/bash
dependencies="guake tmux zsh expect"
dotfiles=".zshrc .tmux.conf .tmux.conf.layout .vrapperrc .gitconfig .my.cnf .alias_functions"
autostart="guake"

# external scripts
CHECK_DEPS=$HOME/bin/check_deps
GET_GITHUB=$HOME/bin/getgithub
VIM_SETUP=$HOME/bin/nvim_setup.sh

# clone/update my scripts repo
sudo apt install git
if [ ! -d $HOME/bin ]
then
    git clone https://github.com/johgh/scripts.git $HOME/bin
fi

$CHECK_DEPS "$dependencies"

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
mkdir ~/.config/autostart 2> /dev/null
for app in $autostart
do
    ln -fs /usr/share/applications/${app}.desktop ~/.config/autostart/
done

# install my vim setup
$VIM_SETUP

echo 'Please reload now .zshrc: "source ~/.zshrc"'
