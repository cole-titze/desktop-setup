#!/usr/bin/env bash
set -euo pipefail

echo "==> Installing Minecraft Bedrock Server (Docker)"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_SOURCE="$ROOT_DIR/files/bedrock.env"
ENV_TARGET="/opt/bedrock/bedrock.env"

# Ensure Docker exists
if ! command -v docker >/dev/null 2>&1; then
  echo "ERROR: Docker not found. Run 50-docker.sh first."
  exit 1
fi

# Create persistent directory
sudo mkdir -p /opt/bedrock/data
sudo chown -R "$USER:$USER" /opt/bedrock

# Copy env file
sudo cp "$ENV_SOURCE" "$ENV_TARGET"
sudo chown "$USER:$USER" "$ENV_TARGET"

# Remove existing container if present (world data preserved)
if docker ps -a --format '{{.Names}}' | grep -qx 'bedrock'; then
  docker rm -f bedrock
fi

# Run container
docker run -d \
  --name bedrock \
  --restart unless-stopped \
  -p 19132:19132/udp \
  -v /opt/bedrock/data:/data \
  --env-file "$ENV_TARGET" \
  itzg/minecraft-bedrock-server

echo "Bedrock server running."
echo "World data: /opt/bedrock/data"
echo "Logs: docker logs -f bedrock"
