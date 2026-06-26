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

UBUNTU_MAJOR=$(lsb_release -rs | cut -d. -f1)

if [[ "$UBUNTU_MAJOR" -ge 24 ]]; then
  # Remove Microsoft repo if present — it conflicts with Ubuntu's native dotnet packages
  if dpkg-query -W -f='${Status}' packages-microsoft-prod 2>/dev/null | grep -q "install ok installed"; then
    sudo apt-get purge -y packages-microsoft-prod
    sudo rm -f /etc/apt/sources.list.d/microsoft-prod.list
    sudo apt-get update
  fi
  # Ubuntu 26.04+ ships dotnet-sdk-10.0 natively; 24.04 ships 8.0/9.0
  if apt-cache show dotnet-sdk-9.0 2>/dev/null | grep -q "ubuntu"; then
    sudo apt-get install -y dotnet-sdk-9.0
  else
    sudo apt-get install -y dotnet-sdk-10.0
  fi
else
  # Older Ubuntu: add Microsoft package repo
  if ! dpkg-query -W -f='${Status}' packages-microsoft-prod 2>/dev/null | grep -q "install ok installed"; then
    UBUNTU_VER=$(lsb_release -rs)
    wget "https://packages.microsoft.com/config/ubuntu/${UBUNTU_VER}/packages-microsoft-prod.deb" -O packages-microsoft-prod.deb
    sudo dpkg -i packages-microsoft-prod.deb
    rm packages-microsoft-prod.deb
    sudo apt-get update
  fi
  sudo apt-get install -y -o Dpkg::Options::="--force-confnew" dotnet-sdk-9.0
fi

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
