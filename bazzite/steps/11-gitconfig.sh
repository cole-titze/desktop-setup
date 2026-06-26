#!/usr/bin/env bash
set -euo pipefail

echo "==> Configuring global Git settings"

git config --global user.name "Cole Titze"
git config --global user.email "cole.titze@outlook.com"

git config --global init.defaultBranch main
git config --global pull.rebase true
git config --global core.editor "code --wait"

echo "11-gitconfig complete"
