#!/usr/bin/env bash
set -euo pipefail

echo "==> Setting up systemd service for Bedrock (Docker)"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SERVICE_SRC="$ROOT_DIR/files/bedrock.service"
ENV_SRC="$ROOT_DIR/files/bedrock.env"

ENV_DIR="/opt/bedrock"
ENV_DST="$ENV_DIR/bedrock.env"

# Prereqs
if ! command -v docker >/dev/null 2>&1; then
  echo "ERROR: docker not found. Run Docker step first." >&2
  exit 1
fi
if [[ ! -f "$SERVICE_SRC" ]]; then
  echo "ERROR: missing $SERVICE_SRC" >&2
  exit 1
fi
if [[ ! -f "$ENV_SRC" ]]; then
  echo "ERROR: missing $ENV_SRC" >&2
  exit 1
fi

# Persistent directories + env file
sudo mkdir -p "$ENV_DIR/data"
sudo cp "$ENV_SRC" "$ENV_DST"
sudo chown -R "$USER:$USER" "$ENV_DIR"

# Install system service
sudo install -m 0644 "$SERVICE_SRC" /etc/systemd/system/bedrock.service

# Enable + start
sudo systemctl daemon-reload
sudo systemctl enable bedrock
sudo systemctl restart bedrock

echo "Bedrock systemd service enabled."
echo "Status: systemctl status bedrock"
echo "Logs:   journalctl -u bedrock -f"
