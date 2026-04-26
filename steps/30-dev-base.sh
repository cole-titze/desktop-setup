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
  wget \
  gh

# Install Microsoft package repository for Ubuntu 22.04 (Pop!_OS jammy)
if ! dpkg-query -W -f='${Status}' packages-microsoft-prod 2>/dev/null | grep -q "install ok installed"; then
  wget https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
  sudo dpkg -i packages-microsoft-prod.deb
  rm packages-microsoft-prod.deb
fi

sudo apt-get update

# Install .NET SDK (pick the version you want)
sudo apt-get install -y \
  -o Dpkg::Options::="--force-confnew" \
  dotnet-sdk-9.0

dotnet tool install -g microsoft.sqlpackage

# Install node
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash

export NVM_DIR="$HOME/.nvm"
set +u
# shellcheck disable=SC1091
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm install --lts
nvm use --lts
set -u

echo "30-dev-base complete"
