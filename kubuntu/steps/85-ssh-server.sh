#!/usr/bin/env bash
set -euo pipefail

echo "==> Installing OpenSSH Server"

sudo apt-get update
sudo apt-get install -y openssh-server

echo "==> Enabling SSH service"

sudo systemctl enable ssh
sudo systemctl start ssh

if sudo systemctl is-active --quiet ssh; then
  echo "SSH is running."
else
  echo "SSH failed to start."
  exit 1
fi

# Allow through firewall if UFW is active
if command -v ufw >/dev/null 2>&1 && sudo ufw status | grep -q active; then
  sudo ufw allow ssh
  echo "SSH allowed through UFW."
fi

echo "85-ssh complete"