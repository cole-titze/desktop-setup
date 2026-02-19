#!/usr/bin/env bash
set -euo pipefail

echo "==> Applying OS settings"

# Disable screen blank
gsettings set org.gnome.desktop.session idle-delay 0

# Disable screen dim
gsettings set org.gnome.settings-daemon.plugins.power idle-dim false

# Disable automatic suspend (AC + battery)
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type 'nothing'

echo "Screen sleep disabled."

# Make text bigger
gsettings set org.gnome.desktop.interface text-scaling-factor 1.1

# --- Power button behavior ---
# Options: 'poweroff', 'interactive', 'suspend', 'hibernate', 'nothing'
gsettings set org.gnome.settings-daemon.plugins.power power-button-action 'interactive'

echo "05-os-settings complete"
