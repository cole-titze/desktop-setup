#!/bin/bash
export WAYLAND_DISPLAY=wayland-0
export XDG_RUNTIME_DIR="/run/user/$(id -u)"

OUTPUT_PRIMARY="DP-1"
OUTPUT_SECONDARY="HDMI-A-1"
OUTPUT_SELF="DP-3"          # iPhone virtual display; explicitly re-enabled too, in case the iPad toggle turned it off
OUTPUT_VIRTUAL_OTHER="DP-2"  # iPad virtual display; must be disabled too or Sunshine sees both virtuals

STATE_FILE="/tmp/iphone-stream-mode"

# SKSE/F4SE launch directly to the loader exe, bypassing the Bethesda
# launcher entirely -- so its resolution/quality picker never shows to let
# these values track the active display. Set them here instead.
GAME_INIS=(
    "$HOME/.local/share/Steam/steamapps/compatdata/489830/pfx/drive_c/users/steamuser/Documents/My Games/Skyrim Special Edition/SkyrimPrefs.ini"
    "$HOME/.local/share/Steam/steamapps/compatdata/377160/pfx/drive_c/users/steamuser/Documents/My Games/Fallout4/Fallout4Prefs.ini"
)

set_game_resolution() {
    local width="$1" height="$2"
    for ini in "${GAME_INIS[@]}"; do
        [ -f "$ini" ] || continue
        sed -i -E "s/^iSize W=.*/iSize W=$width/; s/^iSize H=.*/iSize H=$height/" "$ini"
    done
}

if [ -f "$STATE_FILE" ]; then
    rm "$STATE_FILE"
    kscreen-doctor output.$OUTPUT_PRIMARY.enable \
                   output.$OUTPUT_SECONDARY.enable output.$OUTPUT_SECONDARY.mode.1920x1080@60 \
                   output.$OUTPUT_SELF.enable \
                   output.$OUTPUT_VIRTUAL_OTHER.enable
    # Must be a separate call: KWin re-derives priority as part of enabling an
    # output, so a priority set in the same atomic call as .enable is ignored.
    kscreen-doctor output.$OUTPUT_PRIMARY.priority.1 output.$OUTPUT_SECONDARY.priority.2
    set_game_resolution 2560 1440
else
    touch "$STATE_FILE"
    kscreen-doctor output.$OUTPUT_PRIMARY.disable \
                   output.$OUTPUT_SECONDARY.disable \
                   output.$OUTPUT_VIRTUAL_OTHER.disable
    set_game_resolution 2796 1290
fi
