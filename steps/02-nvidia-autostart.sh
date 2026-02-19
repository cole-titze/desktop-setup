#!/usr/bin/env bash
set -euo pipefail

echo "==> Enabling NVIDIA config load on GNOME login"

AUTOSTART_DIR="$HOME/.config/autostart"
DESKTOP_FILE="$AUTOSTART_DIR/nvidia-load-config.desktop"

mkdir -p "$AUTOSTART_DIR"

cat > "$DESKTOP_FILE" <<'EOF'
[Desktop Entry]
Type=Application
Name=NVIDIA Load Config
Comment=Force load NVIDIA Xorg configuration on login
Exec=sh -lc 'if [ "$XDG_SESSION_TYPE" = "x11" ]; then sleep 3 && nvidia-settings --load-config-only; fi'
X-GNOME-Autostart-enabled=true
X-GNOME-Autostart-Delay=10
EOF

echo "NVIDIA config will load 10 seconds after Xorg login."
echo "To disable later: delete $DESKTOP_FILE"
echo "71-nvidia-load-config complete"
