#!/usr/bin/env bash
set -euo pipefail

echo "==> Installing Bedrock backup-on-stop hook (systemd)"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

SCRIPT_SRC="$ROOT_DIR/files/bedrock-backup.sh"
SCRIPT_DST="/usr/local/bin/bedrock-backup.sh"

DROPIN_DIR="/etc/systemd/system/bedrock.service.d"
DROPIN_SRC="$ROOT_DIR/files/bedrock-backup.conf"
DROPIN_DST="$DROPIN_DIR/backup.conf"

if [[ ! -f "$SCRIPT_SRC" ]]; then
  echo "ERROR: Missing $SCRIPT_SRC" >&2
  exit 1
fi

if [[ ! -f "$DROPIN_SRC" ]]; then
  echo "ERROR: Missing $DROPIN_SRC" >&2
  exit 1
fi

sudo install -m 0755 "$SCRIPT_SRC" "$SCRIPT_DST"
sudo mkdir -p "$DROPIN_DIR"
sudo install -m 0644 "$DROPIN_SRC" "$DROPIN_DST"

sudo systemctl daemon-reload

echo "Minecraft Backup Process Installed. Backups will run whenever bedrock.service stops (including shutdown)."
echo "Backups stored in: /opt/bedrock/backups"
