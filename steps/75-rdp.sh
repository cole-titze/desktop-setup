#!/usr/bin/env bash
set -euo pipefail

echo "==> Installing and enabling RDP (xrdp)"

# Install xrdp
sudo apt-get update
sudo apt-get install -y xrdp

# Enable and start service
sudo systemctl enable xrdp
sudo systemctl start xrdp

# Add xrdp user to ssl-cert group (required on Ubuntu-based systems)
sudo adduser xrdp ssl-cert

echo "RDP installed and enabled."
echo "You can connect using your normal Linux username/password."
echo "Port: 3389"

echo "75-rdp complete"