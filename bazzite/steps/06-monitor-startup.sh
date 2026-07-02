#!/usr/bin/env bash
set -euo pipefail

echo "==> Installing monitors-on-startup autostart script"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

mkdir -p "$HOME/scripts"
install -m 0755 "$ROOT_DIR/files/monitors-on-startup.sh" "$HOME/scripts/monitors-on-startup.sh"

mkdir -p "$HOME/.config/autostart"
install -m 0644 "$ROOT_DIR/files/monitors-on-startup.desktop" "$HOME/.config/autostart/monitors-on-startup.desktop"

echo "06-monitor-startup complete"
echo "Autostart entry installed at ~/.config/autostart/monitors-on-startup.desktop"
echo "If your display outputs differ, update OUTPUT_PRIMARY/OUTPUT_SECONDARY/OUTPUT_VIRTUAL and the position values in ~/scripts/monitors-on-startup.sh"
