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

git add --all ./
git commit -m "$message"
git pull
git push

# jekyll build

cd source
git add --all ./
git commit --amend -m "Deploy. See https://github.com/johgh/johgh.io-source for changes"
git push origin --force

cd ..
git add source
git commit -m "Commited submodule source."
git push
