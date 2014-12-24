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
        echo "sudo apt-get install $packages_to_install"
        sudo apt-get install $packages_to_install
    fi
}

check_deps

# clone conf repo and add symlinks to $HOME
getgithub johgh/dotfiles conf
# git clone https://github.com/johgh/dotfiles $HOME/conf
cd $HOME
ln -fs $HOME/bin/.zshrc .
ln -fs $HOME/bin/.tmux.conf .
ln -fs $HOME/bin/.vrapperrc .
ln -fs $HOME/bin/.tmux.conf.layout .
ln -fs $HOME/bin/conf/.gitconfig .
cd -

# clone scripts repo
getgithub johgh/scripts bin
# git clone https://github.com/johgh/scripts $HOME/bin

# add to path
getgithub robbyrussell/oh-my-zsh.git .oh-my-zsh
# git clone git://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh
chsh -s /bin/zsh

if [ ! -z $1 ]
then
    $HOME/bin/vim_setup.sh $1
fi

# add guake to startup
cp /usr/share/applications/guake.desktop ~/.config/autostart/

# warning reload .zshrc
echo 'load now .zshrc with "source ~/.zshrc"'
