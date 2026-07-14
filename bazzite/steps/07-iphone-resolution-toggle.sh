#!/usr/bin/env bash
set -euo pipefail

echo "==> Installing iPhone resolution toggle"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

mkdir -p "$HOME/scripts"
install -m 0755 "$ROOT_DIR/files/iphone-resolution-toggle.sh" "$HOME/scripts/iphone-resolution-toggle.sh"

mkdir -p "$HOME/Desktop"
install -m 0644 "$ROOT_DIR/files/iphone-resolution-toggle.desktop" "$HOME/Desktop/iphone-resolution-toggle.desktop"
gio set "$HOME/Desktop/iphone-resolution-toggle.desktop" metadata::trusted true

echo "07-iphone-resolution-toggle complete"
echo "Toggle script installed at ~/scripts/iphone-resolution-toggle.sh"
echo "Desktop shortcut installed at ~/Desktop/iphone-resolution-toggle.desktop"
echo "If your display outputs differ, update OUTPUT_PRIMARY/OUTPUT_SECONDARY in ~/scripts/iphone-resolution-toggle.sh"
echo "Run 'kscreen-doctor -o' to find the correct output names."
