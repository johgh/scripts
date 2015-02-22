#!/bin/bash
(
killall ruby1.9.1 & > /dev/null 2>&1
cd $HOME/johgh.io-source
bundle exec jekyll serve --watch & > /dev/null 2>&1
)
