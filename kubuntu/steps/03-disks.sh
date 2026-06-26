#!/usr/bin/env bash
set -euo pipefail

# steps/03-disks.sh
# Mount the 1TB secondary NVMe (nvme1n1p1) at /mnt/data via fstab.

echo "==> Disks: configure /mnt/data auto-mount"

MOUNT_POINT="/mnt/data"
UUID="57626a5d-4306-4215-87a0-6816fda1b41c"
FSTAB_ENTRY="UUID=${UUID} ${MOUNT_POINT} ext4 defaults 0 2"

sudo mkdir -p "$MOUNT_POINT"

if grep -q "$UUID" /etc/fstab; then
  echo "fstab entry already present, skipping"
else
  echo "$FSTAB_ENTRY" | sudo tee -a /etc/fstab
  sudo systemctl daemon-reload
  sudo mount "$MOUNT_POINT"
  echo "Mounted $MOUNT_POINT"
fi

echo "03-disks complete"
