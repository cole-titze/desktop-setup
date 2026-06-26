#!/usr/bin/env bash
set -euo pipefail

DATA_DIR="/opt/bedrock/data/worlds"
BACKUP_DIR="/opt/bedrock/backups"
TS="$(date +'%Y-%m-%d_%H-%M-%S')"
OUT="${BACKUP_DIR}/bedrock_${TS}.tar.gz"

mkdir -p "$BACKUP_DIR"

# If data dir doesn't exist, nothing to do
if [[ ! -d "$DATA_DIR" ]]; then
  exit 0
fi

tar -czf "$OUT" -C "$DATA_DIR" .

# keep last 15 backups
ls -1t "${BACKUP_DIR}"/bedrock_*.tar.gz 2>/dev/null | tail -n +11 | xargs -r rm -f
