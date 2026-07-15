#!/usr/bin/env bash
set -euo pipefail

echo "==> Pre-authorizing Sunshine for KDE remote-desktop/screencast portals"

APP_ID="dev.lizardbyte.app.Sunshine"

if ! flatpak info "$APP_ID" >/dev/null 2>&1; then
  echo "Sunshine flatpak ($APP_ID) not installed — install it via Bazzite Portal first. Skipping."
  exit 0
fi

flatpak permission-set kde-authorized remote-desktop "$APP_ID" yes
flatpak permission-set kde-authorized screencast "$APP_ID" yes

echo "08-sunshine-permissions complete"
echo "KWin will no longer prompt locally for screen/input access before a Moonlight connection can stream."
echo "If prompts still appear, restart Sunshine: systemctl --user restart app-${APP_ID}.service"
