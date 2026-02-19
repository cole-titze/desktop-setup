#!/usr/bin/env bash
set -euo pipefail

echo "==> Configuring Sunshine to start on login"

mkdir -p "$HOME/.config/autostart"

cat > "$HOME/.config/autostart/sunshine.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=Sunshine
Exec=flatpak run dev.lizardbyte.app.Sunshine
X-GNOME-Autostart-enabled=true
EOF

echo "Sunshine will now start automatically on login."
echo "27-sunshine-autostart complete"
