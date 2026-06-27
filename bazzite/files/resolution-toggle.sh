#!/bin/bash
export DISPLAY=:0
export XAUTHORITY="$HOME/.Xauthority"

# Update these to match your outputs — run: xrandr | grep ' connected'
OUTPUT_PRIMARY="DP-0"
OUTPUT_SECONDARY="HDMI-0"
NORMAL_RES="2560x1440"
IPAD_RES="2752x2064"

STATE_FILE="/tmp/ipad-stream-mode"

if [ -f "$STATE_FILE" ]; then
    rm "$STATE_FILE"
    xrandr --output "$OUTPUT_PRIMARY" --mode "$NORMAL_RES" --scale 1x1 \
           --output "$OUTPUT_SECONDARY" --mode 1920x1080 --right-of "$OUTPUT_PRIMARY"
else
    touch "$STATE_FILE"
    xrandr --output "$OUTPUT_PRIMARY" --mode "$NORMAL_RES" \
           --fb "$IPAD_RES" --scale-from "$IPAD_RES" \
           --output "$OUTPUT_SECONDARY" --off
fi
