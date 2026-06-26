echo "==> Setting NVIDIA viewport on login"

mkdir -p "$HOME/.config/autostart"

cat << EOF > "$HOME/.config/autostart/nvidia-viewport.desktop"
[Desktop Entry]
Type=Application
Exec=/usr/bin/nvidia-settings --assign CurrentMetaMode=DPY-1:\ 2560x1440_144\ +0+0\ {ViewPortIn=2752x2064,\ ViewPortOut=2560x1440+0+0}
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=NVIDIA Viewport
EOF

echo "02-nvidia-viewport complete"