#!/usr/bin/env bash
set -euo pipefail

echo "==> Cleaning up unused packages"

sudo apt autoremove -y
sudo apt autoclean -y

echo "Cleanup complete"
