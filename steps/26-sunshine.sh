#!/usr/bin/env bash
set -euo pipefail

echo "==> Installing Sunshine from Pop!_OS repositories"

sudo apt update
sudo apt install -y sunshine

echo "Sunshine installed via apt."
echo "Test it with: sunshine"
echo "Pop! repo version avoids the libminiupnpc mismatch."
echo "60-sunshine-apt complete"
