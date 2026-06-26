#!/usr/bin/env bash
set -euo pipefail

echo "==> Enabling Steam auto-start (GNOME session, 5s delay)"

AUTOSTART_DIR="$HOME/.config/autostart"
DESKTOP_FILE="$AUTOSTART_DIR/steam.desktop"

mkdir -p "$AUTOSTART_DIR"

cat > "$DESKTOP_FILE" <<'EOF'
[Desktop Entry]
Type=Application
Name=Steam
Comment=Start Steam on login
Exec=steam -silent -pipewire
X-GNOME-Autostart-enabled=true
X-GNOME-Autostart-Delay=5
EOF

echo "Steam will start 5 seconds after login."
echo "To disable later: delete $DESKTOP_FILE"
echo "25-steam-autostart complete"
