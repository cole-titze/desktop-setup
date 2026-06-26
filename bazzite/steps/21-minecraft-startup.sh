#!/usr/bin/env bash
set -euo pipefail

echo "==> Setting up systemd service for Bedrock (Podman)"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SERVICE_SRC="$ROOT_DIR/files/bedrock.service"
ENV_SRC="$ROOT_DIR/files/bedrock.env"

ENV_DIR="/opt/bedrock"
ENV_DST="$ENV_DIR/bedrock.env"

if ! command -v podman >/dev/null 2>&1; then
  echo "ERROR: Podman not found. It should be pre-installed on Bazzite." >&2
  exit 1
fi
if [[ ! -f "$SERVICE_SRC" ]]; then
  echo "ERROR: missing $SERVICE_SRC" >&2
  exit 1
fi

sudo mkdir -p "$ENV_DIR/data"
sudo cp "$ENV_SRC" "$ENV_DST"
sudo chown -R "$USER:$USER" "$ENV_DIR"

sudo install -m 0644 "$SERVICE_SRC" /etc/systemd/system/bedrock.service
sudo systemctl daemon-reload
sudo systemctl enable bedrock
sudo systemctl restart bedrock

echo "Bedrock systemd service enabled."
echo "Status: systemctl status bedrock"
echo "Logs:   journalctl -u bedrock -f"
echo "21-minecraft-startup complete"
