#!/usr/bin/env bash
set -euo pipefail

echo "==> Installing iPad resolution toggle"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

mkdir -p "$HOME/scripts"
install -m 0755 "$ROOT_DIR/files/resolution-toggle.sh" "$HOME/scripts/resolution-toggle.sh"

mkdir -p "$HOME/Desktop"
install -m 0755 "$ROOT_DIR/files/resolution-toggle.desktop" "$HOME/Desktop/resolution-toggle.desktop"

echo "05-resolution-toggle complete"
echo "Desktop shortcut created at ~/Desktop"
echo "If your display outputs differ, update OUTPUT_PRIMARY/OUTPUT_SECONDARY in ~/scripts/resolution-toggle.sh"
echo "Run 'xrandr | grep connected' to find the correct output names."
