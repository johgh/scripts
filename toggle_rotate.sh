#!/bin/bash

# Define your display name (replace 'DISPLAY_NAME' with your actual display name)
DISPLAY_NAME="HDMI-A-0"

# Get the current screen orientation
CURRENT_ORIENTATION=$(xrandr --query --verbose | grep "$DISPLAY_NAME" | awk -F ' ' '{print $6}')

# Toggle between right and normal landscape orientation
if [ "$CURRENT_ORIENTATION" == "right" ]; then
        xrandr --output "$DISPLAY_NAME" --rotate normal
    else
            xrandr --output "$DISPLAY_NAME" --rotate right
fi

