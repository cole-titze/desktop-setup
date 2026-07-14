#!/bin/bash
# Force physical monitors on and DP-1 primary at every login. KWin overwrites
# its saved output layout with whatever the live enabled/disabled state was
# the last time this exact set of outputs was connected -- so if the machine
# is shut down or rebooted while resolution-toggle.sh or
# iphone-resolution-toggle.sh has the physical monitors disabled (streaming
# mode), KWin boots back into that same "monitors off" layout. This runs
# unconditionally on every session start to override that, regardless of
# what was last saved.
export WAYLAND_DISPLAY=wayland-0
export XDG_RUNTIME_DIR="/run/user/$(id -u)"

OUTPUT_PRIMARY="DP-1"
OUTPUT_SECONDARY="HDMI-A-1"
OUTPUT_VIRTUAL_IPAD="DP-2"
OUTPUT_VIRTUAL_IPHONE="DP-3"

# Give KWin time to enumerate outputs and apply its own saved config first,
# so we're overriding it rather than racing it.
sleep 8

kscreen-doctor output.$OUTPUT_PRIMARY.enable output.$OUTPUT_SECONDARY.enable \
               output.$OUTPUT_VIRTUAL_IPAD.enable output.$OUTPUT_VIRTUAL_IPHONE.enable
kscreen-doctor output.$OUTPUT_PRIMARY.priority.1 \
               output.$OUTPUT_SECONDARY.priority.2 \
               output.$OUTPUT_VIRTUAL_IPAD.priority.3 \
               output.$OUTPUT_VIRTUAL_IPHONE.priority.4
kscreen-doctor output.$OUTPUT_PRIMARY.position.0,0 \
               output.$OUTPUT_SECONDARY.position.1707,0 \
               output.$OUTPUT_VIRTUAL_IPAD.position.2787,0 \
               output.$OUTPUT_VIRTUAL_IPHONE.position.4011,0

rm -f /tmp/ipad-stream-mode /tmp/iphone-stream-mode
