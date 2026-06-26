#!/usr/bin/env bash
set -euo pipefail

echo "==> Configuring global Git settings"

# Set identity
git config --global user.name "Cole Titze"
git config --global user.email "cole.titze@outlook.com"

# defaults
git config --global init.defaultBranch main
git config --global pull.rebase true
git config --global core.editor "code --wait"

echo "31-gitconfig complete"
