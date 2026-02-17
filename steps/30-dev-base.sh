#!/usr/bin/env bash
set -euo pipefail

echo "==> Installing base development tools"

sudo apt-get update
sudo apt-get install -y \
  git \
  build-essential \
  python3 \
  python3-venv \
  python3-pip \
  wget

# Install Microsoft package repository for Ubuntu 22.04 (Pop!_OS jammy)
if ! dpkg -s packages-microsoft-prod >/dev/null 2>&1; then
  wget https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
  sudo dpkg -i packages-microsoft-prod.deb
  rm packages-microsoft-prod.deb
fi

sudo apt-get update

# Install .NET SDK (pick the version you want)
sudo apt-get install -y \
  -o Dpkg::Options::="--force-confnew" \
  dotnet-sdk-9.0

echo "30-dev-base complete"
