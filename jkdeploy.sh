#!/bin/bash
set -e
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
git commit -m "$message (deploy)"
git push
cd ..
git add --all ./
git commit -m "$message"
git push
