#!/usr/bin/env bash
set -euo pipefail

echo "==> Setting up Steam Remote Play toggle"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FILES_DIR="$SCRIPT_DIR/../files"

mkdir -p "$HOME/scripts"

cp "$FILES_DIR/remote-toggle.sh" "$HOME/scripts/remote-toggle.sh"
chmod +x "$HOME/scripts/remote-toggle.sh"

cp "$FILES_DIR/steam-remote.desktop" "$HOME/Desktop/Steam Remote.desktop"
chmod +x "$HOME/Desktop/Steam Remote.desktop"

echo "Steam Remote Play toggle installed."
echo "  Desktop shortcut: ~/Desktop/Steam Remote.desktop"
echo "  First run: right-click the icon and select 'Allow Launching'"
echo "  Toggle on:  2752x2064 virtual framebuffer, 200% scale, HDMI-0 off"
echo "  Toggle off: 2560x1440, 100% scale, HDMI-0 restored"
echo "28-steam-remote-play complete"
