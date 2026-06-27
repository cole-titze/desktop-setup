#!/bin/bash
export WAYLAND_DISPLAY=wayland-0
export XDG_RUNTIME_DIR="/run/user/$(id -u)"

OUTPUT_PRIMARY="DP-1"
OUTPUT_SECONDARY="HDMI-A-1"

STATE_FILE="/tmp/ipad-stream-mode"

if [ -f "$STATE_FILE" ]; then
    rm "$STATE_FILE"
    kscreen-doctor output.$OUTPUT_PRIMARY.enable \
                   output.$OUTPUT_SECONDARY.enable output.$OUTPUT_SECONDARY.mode.1920x1080@60
else
    touch "$STATE_FILE"
    kscreen-doctor output.$OUTPUT_PRIMARY.disable \
                   output.$OUTPUT_SECONDARY.disable
fi
