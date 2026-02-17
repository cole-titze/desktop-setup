#!/usr/bin/env bash
set -euo pipefail

echo "==> Installing base development tools"

# Install Microsoft package repository for .NET SDK
wget https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
sudo apt update

sudo apt install -y \
  git \
  build-essential \
  python3 \
  python3-venv \
  python3-pip \
  dotnet-sdk-7.0 \
  dotnet-sdk-8.0 \
  dotnet-sdk-9.0 \
  dotnet-sdk-10.0

echo "30-dev-base complete"
