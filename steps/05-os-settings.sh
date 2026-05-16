#!/usr/bin/env bash
set -euo pipefail

echo "==> Applying OS settings (KDE Plasma)"

# Disable screen auto-lock
kwriteconfig5 --file kscreenlockerrc --group Daemon --key Autolock false

# Disable DPMS screen-off, dim, and suspend on idle (AC power)
kwriteconfig5 --file powermanagementprofilesrc --group "AC" --group "DPMSControl" --key idleTime 0
kwriteconfig5 --file powermanagementprofilesrc --group "AC" --group "BrightnessControl" --key idleTime 0
kwriteconfig5 --file powermanagementprofilesrc --group "AC" --group "SuspendSession" --key idleTime 0

echo "Screen sleep and auto-lock disabled."

# Make text slightly bigger (~1.1×; default DPI is 96)
kwriteconfig5 --file kcmfonts --group General --key forceFontDPI 106

# Power button: show interactive logout/power dialog
# Verify in System Settings > Power Management > Button Events if this needs adjusting
kwriteconfig5 --file powermanagementprofilesrc --group "AC" --group "HandleButtonEvents" --key powerButtonAction 16

# Signal running Plasma session to reload power settings (no-op at install time)
qdbus org.kde.Solid.PowerManagement /org/kde/Solid/PowerManagement \
  org.kde.Solid.PowerManagement.refreshStatus 2>/dev/null || true

# Force X11 session — SDDM autologin defaults to 'plasma' which is Wayland in Plasma 6
sudo sed -i 's/^Session=.*/Session=plasmax11/' /etc/sddm.conf

echo "05-os-settings complete"
