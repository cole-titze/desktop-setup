#!/usr/bin/env bash
set -euo pipefail

echo "==> Configuring SSH"

# Generate key if not present
if [[ ! -f "$HOME/.ssh/id_ed25519" ]]; then
  ssh-keygen -t ed25519 -C "cole.titze@outlook.com"
else
  echo "SSH key already exists, skipping keygen."
fi

echo "Public key:"
cat "$HOME/.ssh/id_ed25519.pub"
echo
echo "Add this key to GitHub: https://github.com/settings/ssh/new"

# sshd is pre-installed on Bazzite — just enable it
sudo systemctl enable --now sshd

echo "15-ssh complete"
