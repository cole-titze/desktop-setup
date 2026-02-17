#!/usr/bin/env bash
set -euo pipefail

echo "==> Configuring static IP for Ethernet (Netplan)"

# ===== EDIT THESE =====
INTERFACE="enp3s0"          # Run `ip a` to confirm
STATIC_IP="10.42.0.50/24"   # Your desired static IP
GATEWAY="10.42.0.1"         # Your router / Pi-hole gateway
DNS1="10.42.0.2"            # Your Pi-hole IP
DNS2="10.42.0.2"
# ======================

NETPLAN_FILE="/etc/netplan/99-static.yaml"

sudo tee "$NETPLAN_FILE" > /dev/null <<EOF
network:
  version: 2
  renderer: NetworkManager
  ethernets:
    ${INTERFACE}:
      dhcp4: false
      addresses:
        - ${STATIC_IP}
      routes:
        - to: default
          via: ${GATEWAY}
      nameservers:
        addresses: [${DNS1}, ${DNS2}]
EOF

sudo netplan apply

echo "✅ Static IP applied."
echo "Verify with: ip a && ip route"