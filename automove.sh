#!/bin/bash

# apps ID
wavebox=`wmctrl -l | grep Wavebox | cut -d ' ' -f1`
lollypop=`wmctrl -l | grep Lollypop | cut -d ' ' -f1`
# chrome=`wmctrl -l | grep -E 'Chromium|Chrome' | cut -d ' ' -f1`

# move to desktop 0
# wmctrl -i -r $chrome -t 1 2> /dev/null

# move to desktop 1
wmctrl -i -r $wavebox -t 1 2> /dev/null
wmctrl -i -r $lollypop -t 1 2> /dev/null

