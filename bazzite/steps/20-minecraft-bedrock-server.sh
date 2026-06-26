#!/usr/bin/env bash
set -euo pipefail

echo "==> Installing Minecraft Bedrock Server (Podman)"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_SOURCE="$ROOT_DIR/files/bedrock.env"
ENV_TARGET="/opt/bedrock/bedrock.env"

if ! command -v podman >/dev/null 2>&1; then
  echo "ERROR: Podman not found. It should be pre-installed on Bazzite." >&2
  exit 1
fi

sudo mkdir -p /opt/bedrock/data
sudo chown -R "$USER:$USER" /opt/bedrock

sudo cp "$ENV_SOURCE" "$ENV_TARGET"
sudo chown "$USER:$USER" "$ENV_TARGET"

if podman ps -a --format '{{.Names}}' | grep -qx 'bedrock'; then
  podman rm -f bedrock
fi

podman run -d \
  --name bedrock \
  -p 19132:19132/udp \
  -v /opt/bedrock/data:/data \
  --env-file "$ENV_TARGET" \
  docker.io/itzg/minecraft-bedrock-server

echo "Bedrock server running."
echo "World data: /opt/bedrock/data"
echo "Logs: podman logs -f bedrock"
echo "20-minecraft-bedrock-server complete"
