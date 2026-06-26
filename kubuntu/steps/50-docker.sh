#!/usr/bin/env bash
set -euo pipefail

echo "==> Installing Docker"

# Install using official script
if ! command -v docker >/dev/null 2>&1; then
  curl -fsSL https://get.docker.com | sudo sh
else
  echo "Docker already installed, skipping."
fi

# Add current user to docker group
sudo usermod -aG docker "$USER"

# Enable Docker on boot
sudo systemctl enable docker
sudo systemctl start docker

echo "You must log out and back in (or reboot) before using docker without sudo."

echo "50-docker complete"
