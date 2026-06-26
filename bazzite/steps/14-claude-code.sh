#!/usr/bin/env bash
set -euo pipefail

echo "==> Installing Claude Code"

# Each step runs in a fresh bash subprocess, so source nvm to get node/npm in PATH
NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
if [[ -s "$NVM_DIR/nvm.sh" ]]; then
  set +u
  # shellcheck disable=SC1091
  \. "$NVM_DIR/nvm.sh"
  set -u
else
  echo "ERROR: nvm not found at $NVM_DIR — run 10-dev-base.sh first." >&2
  exit 1
fi

curl -fsSL https://claude.ai/install.sh | bash

echo "Run claude in terminal to complete setup."
echo "14-claude-code complete"
