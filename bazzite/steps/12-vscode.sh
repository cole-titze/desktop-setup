#!/usr/bin/env bash
set -euo pipefail

echo "==> Installing VS Code (Flatpak)"

if ! flatpak list --app | grep -q 'com.visualstudio.code'; then
  flatpak install -y flathub com.visualstudio.code
else
  echo "VS Code already installed, skipping."
fi

echo "12-vscode complete"
echo "Launch VS Code via: flatpak run com.visualstudio.code"
