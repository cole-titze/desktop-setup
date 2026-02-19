#!/usr/bin/env bash
set -euo pipefail

echo "==> Installing Sunshine (Flatpak)"

# Ensure Flatpak is installed
if ! command -v flatpak >/dev/null 2>&1; then
  echo "Flatpak not found. Installing..."
  sudo apt-get update
  sudo apt-get install -y flatpak
fi

# Ensure Flathub remote exists
if ! flatpak remotes | grep -q flathub; then
  echo "Adding Flathub remote..."
  flatpak remote-add --if-not-exists flathub \
    https://flathub.org/repo/flathub.flatpakrepo
fi

# Install Sunshine if not already installed
if ! flatpak list | grep -q dev.lizardbyte.app.Sunshine; then
  flatpak install -y flathub dev.lizardbyte.app.Sunshine
  flatpak run --command=additional-install.sh dev.lizardbyte.app.Sunshine
else
  echo "Sunshine already installed."
fi

echo "26-sunshine complete"
