#!/bin/bash

dependencies="guake wmctrl tmux zsh build-essential cmake python-dev"
check_deps()
{
    deps_ok=1
    for dep in $dependencies
    do
        if ! $(which $dep &>/dev/null); then
            packages_to_install=" ${dep}"
            deps_ok=0
        fi
    done

    if [[ $deps_ok == 0 ]]; then
        sudo apt-get install $packages_to_install
    fi
}

check_deps

# clone conf repo and add symlinks to $HOME
git clone https://github.com/johgh/dotfiles $HOME/conf
cd $HOME
ln -s $HOME/bin/.zshrc .
ln -s $HOME/bin/.tmux.conf .
ln -s $HOME/bin/.vrapperrc .
ln -s $HOME/bin/.tmux.conf.layout .
ln -s $HOME/bin/conf/.gitconfig .
cd -

# clone scripts repo
git clone https://github.com/johgh/scripts $HOME/bin
echo "export PATH=$HOME/bin:$PATH" >> ~/.zshrc

# add to path
git clone git://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh
chsh -s /bin/zsh

if [ ! -z $1 ]
then
    ./vim_setup.sh
fi

# add guake to startup
cp /usr/share/applications/guake.desktop ~/.config/autostart/

