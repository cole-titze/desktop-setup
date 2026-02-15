#!/usr/bin/env bash
set -euo pipefail

echo "==> Installing VS Code"

if ! command -v code >/dev/null 2>&1; then
  wget -qO- https://packages.microsoft.com/keys/microsoft.asc \
    | gpg --dearmor \
    | sudo tee /usr/share/keyrings/microsoft.gpg >/dev/null

  echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/code stable main" \
    | sudo tee /etc/apt/sources.list.d/vscode.list >/dev/null

  sudo apt update
  sudo apt install -y code
else
  echo "VS Code already installed, skipping."
fi

echo "40-vscode complete"
