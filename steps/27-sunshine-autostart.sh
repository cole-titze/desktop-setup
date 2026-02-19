#!/usr/bin/env bash
set -euo pipefail

echo "==> Enabling Sunshine to start on login (systemd user service)"

if ! command -v sunshine >/dev/null 2>&1; then
  echo "ERROR: sunshine not found. Install it first with:"
  echo "  sudo apt install sunshine"
  exit 1
fi

UNIT_DIR="$HOME/.config/systemd/user"
UNIT_FILE="$UNIT_DIR/sunshine.service"

mkdir -p "$UNIT_DIR"

cat > "$UNIT_FILE" <<'EOF'
[Unit]
Description=Sunshine (Moonlight host)

[Service]
ExecStart=/usr/bin/sunshine
Restart=on-failure
RestartSec=2

[Install]
WantedBy=default.target
EOF

systemctl --user daemon-reload
systemctl --user enable --now sunshine.service

echo ""
echo "Sunshine enabled for login."
echo "Check status with:"
echo "  systemctl --user status sunshine.service"
echo ""
echo "View logs with:"
echo "  journalctl --user -u sunshine.service -b --no-pager"
echo ""
echo "62-sunshine-user-service complete"
