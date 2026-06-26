#!/usr/bin/env bash
set -euo pipefail

echo "==> Installing base packages"

sudo apt install -y \
  build-essential \
  htop \
  neovim \
  unzip \
  zip \
  tree \
  jq \
  net-tools

echo "10-packages complete"
