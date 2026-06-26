#!/usr/bin/env bash
set -euo pipefail

echo "==> Generating SSH key (if not exists)"

if [[ ! -f "$HOME/.ssh/id_ed25519" ]]; then
  ssh-keygen -t ed25519 -C "cole.titze@outlook.com"
else
  echo "SSH key already exists, skipping."
fi

echo "Public key:"
cat "$HOME/.ssh/id_ed25519.pub"
echo
echo "Add this key to GitHub or other services."

echo "SSH key step complete"
