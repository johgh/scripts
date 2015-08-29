#!/bin/bash
set -e

# save current directory
dir=`pwd`

if [[ -z $1 ]]
then
    echo 'Provide message'
    exit 1
fi

message=$1

cd $HOME/johgh.io-source
jekyll build

cd source
git add --all ./
git commit --amend -m "Deploy. See https://github.com/johgh/johgh.io-source for changes"
git push origin --force

cd ..
git add --all ./
git commit -m "$message"
git pull
git push
