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
git commit -m "$message (deploy)"
# executes push and sends pass automatically
$dir/push

cd ..
git add --all ./
git commit -m "$message"
git push
