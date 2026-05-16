#!/usr/bin/env bash
set -euo pipefail

echo "==> Installing Sunshine (Flatpak)"

if ! flatpak info dev.lizardbyte.app.Sunshine >/dev/null 2>&1; then
  flatpak install -y flathub dev.lizardbyte.app.Sunshine
fi

echo "26-sunshine complete"
