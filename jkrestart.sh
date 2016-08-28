#!/bin/bash
killall ruby2.2 & > /dev/null 2>&1
killall ruby2.3 & > /dev/null 2>&1
cd $HOME/johgh.io-source
bundle exec jekyll serve --port 8000 --no-watch --detach
