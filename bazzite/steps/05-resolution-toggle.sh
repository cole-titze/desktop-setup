#!/usr/bin/env bash
set -euo pipefail

echo "==> Installing iPad resolution toggle"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

mkdir -p "$HOME/scripts"
install -m 0755 "$ROOT_DIR/files/resolution-toggle.sh" "$HOME/scripts/resolution-toggle.sh"

echo "05-resolution-toggle complete"
echo "Toggle script installed at ~/scripts/resolution-toggle.sh"
echo "If your display outputs differ, update OUTPUT_PRIMARY/OUTPUT_SECONDARY in ~/scripts/resolution-toggle.sh"
echo "Run 'kscreen-doctor -o' to find the correct output names."
