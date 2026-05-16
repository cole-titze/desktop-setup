#!/usr/bin/env bash
set -euo pipefail

echo "==> Installing Sunshine (Flatpak)"

if ! command -v flatpak >/dev/null 2>&1; then
  sudo apt install -y flatpak
fi

# Add Flathub remote if not already present
if ! flatpak remote-list | grep -q flathub; then
  flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
fi

if ! flatpak info dev.lizardbyte.app.Sunshine >/dev/null 2>&1; then
  flatpak install -y flathub dev.lizardbyte.app.Sunshine
fi

echo "Sunshine installed. Visit https://localhost:47990 after first launch to configure."
echo "26-sunshine complete"
