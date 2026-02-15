#!/usr/bin/env bash
set -euo pipefail

# steps/00-system.sh
# Base system prep: update/upgrade + a few essentials you’ll want for the rest of the bootstrap.

echo "==> System: update + essentials"

# Update OS packages
sudo apt update
sudo apt upgrade -y

# Core tools used by later steps (git/curl/etc.)
sudo apt install -y \
  git \
  curl \
  wget \
  ca-certificates \
  gnupg \
  lsb-release \
  software-properties-common

echo "00-system complete"
