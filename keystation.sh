#!/bin/bash
xhost local:jhv
export DISPLAY=:0.0
sleep 3
su jhv -c 'qjackctl &'
sleep 3
su jhv -c qsynth
