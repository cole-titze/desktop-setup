#!/usr/bin/env bash
set -euo pipefail

echo "==> Installing base development tools"

sudo apt install -y \
  git \
  build-essential \
  python3 \
  python3-venv \
  python3-pip \
  dotnet-sdk

echo "30-dev-base complete"
