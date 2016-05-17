#!/bin/bash
if [[ `xrandr | grep '*' | grep '2560' | wc -l` -eq 1 ]]; then
    xrandr --output HDMI2 --mode 1920x1080
else
    xrandr --output HDMI2 --mode 2560x1080
fi
