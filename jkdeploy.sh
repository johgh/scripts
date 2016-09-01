#!/bin/bash
set -e
# see "help set"

# get git pass
. $HOME/conf/.alias_functions

if [[ -z $1 ]]
then
    echo 'Provide message'
    exit 1
fi

message=$1

# killall jkwatch > /dev/null 2>&1 &

cd $HOME/johgh.io-source

/usr/bin/git add --all ./
/usr/bin/git commit -m "$message"
/usr/bin/git pull
$HOME/bin/ansbot '*?assword*' $GIT_PASS ''/usr/bin/git p''

# jekyll build

cd source
/usr/bin/git add --all ./
/usr/bin/git commit --amend -m "Deploy. See https://github.com/johgh/johgh.io-source for changes"
$HOME/bin/ansbot '*?assword*' $GIT_PASS ''/usr/bin/git p origin --force''

cd ..
/usr/bin/git add source
/usr/bin/git commit -m "Commited submodule source."
$HOME/bin/ansbot '*?assword*' $GIT_PASS ''/usr/bin/git p''
