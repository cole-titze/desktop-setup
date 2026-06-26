#!/usr/bin/env bash
set -euo pipefail

echo "==> Installing Steam"

# Enable 32-bit support (required for Steam + many games)
sudo dpkg --add-architecture i386
sudo apt update

# Install Steam
sudo apt install -y steam

echo "20-steam complete"
echo "Launch Steam from the app menu to finish initial setup."
