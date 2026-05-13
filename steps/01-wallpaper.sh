#!/usr/bin/env bash
set -euo pipefail

echo "==> Setting desktop wallpaper (KDE Plasma)"

# Resolve script directory (works even if run from elsewhere)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WALLPAPER="$(realpath "$SCRIPT_DIR/../files/wallpaper.jpg")"

if [ ! -f "$WALLPAPER" ]; then
  echo "Wallpaper not found at $WALLPAPER"
  exit 1
fi

# plasma-apply-wallpaperimage available in Plasma 5.23+ (Kubuntu 22.04+)
plasma-apply-wallpaperimage "$WALLPAPER"

echo "Wallpaper set successfully"
echo "01-wallpaper complete"
