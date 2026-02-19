#!/usr/bin/env bash
set -euo pipefail

echo "==> Installing NVIDIA Xorg drop-in (viewportin 2752x2064)"

CONF_DIR="/etc/X11/xorg.conf.d"
CONF_FILE="$CONF_DIR/10-nvidia-viewport.conf"

# Create dir if missing
sudo mkdir -p "$CONF_DIR"

# Write minimal drop-in. This avoids a giant /etc/X11/xorg.conf.
sudo tee "$CONF_FILE" >/dev/null <<'EOF'
# Force NVIDIA metamodes viewport on Xorg
Section "Screen"
    Identifier "Screen0"
    Option "metamodes" "2560x1440_144 +0+0 {viewportin=2752x2064}"
EndSection
EOF

echo "Wrote: $CONF_FILE"

# Remove monolithic config if present (it can override/conflict)
if [ -f /etc/X11/xorg.conf ]; then
  sudo mv /etc/X11/xorg.conf "/etc/X11/xorg.conf.bak.$(date +%Y%m%d%H%M%S)"
  echo "Moved existing /etc/X11/xorg.conf to a backup (drop-in is now authoritative)."
fi

echo "70-nvidia-xorg-viewport-dropin complete"
