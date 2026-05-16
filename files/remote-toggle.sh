#!/bin/bash
export DISPLAY=:0
export XAUTHORITY=/home/cole/.Xauthority

STATE_FILE="/tmp/steam-remote-mode"

if [ -f "$STATE_FILE" ]; then
    rm "$STATE_FILE"
    xrandr --output DP-0 --mode 2560x1440 --scale 1x1 --output HDMI-0 --mode 1920x1080 --right-of DP-0
else
    touch "$STATE_FILE"
    xrandr --output DP-0 --mode 2560x1440 --fb 2752x2064 --scale-from 2752x2064 --output HDMI-0 --off
fi
