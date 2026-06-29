# desktop-setup

Bootstrap scripts for a fresh desktop install. Two setups are available:

| Setup | Folder | OS |
|-------|--------|----|
| Kubuntu | `kubuntu/` | Kubuntu 24.04 LTS — full desktop (KDE, Steam, Sunshine, Docker, Minecraft) |
| Bazzite | `bazzite/` | Bazzite — dev tools + Minecraft only (Steam/gaming is pre-installed on Bazzite) |

---

## Kubuntu

### Standard route

#### 1. Install the OS
[Download Kubuntu 24.04 LTS](https://kubuntu.org/getkubuntu/) and do a clean install.

#### 2. Clone and run
```bash
sudo apt-get update && sudo apt-get install -y git
git clone https://github.com/cole-titze/desktop-setup.git
cd desktop-setup
bash kubuntu/setup.sh
```

#### 3. Add SSH key to GitHub
The setup generates `~/.ssh/id_ed25519` and prints the public key. Add it at:
https://github.com/settings/ssh/new

### Agent route

#### 1. Install the OS and bootstrap Node + Claude Code
```bash
sudo apt-get update && sudo apt-get install -y git curl
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
source ~/.nvm/nvm.sh
nvm install --lts
curl -fsSL https://claude.ai/install.sh | bash
```

#### 2. Clone the repo and let Claude run the setup
```bash
git clone https://github.com/cole-titze/desktop-setup.git
cd desktop-setup
claude "Run bash kubuntu/setup.sh -y to fully set up this Kubuntu machine"
```

#### 3. Add SSH key to GitHub
Claude will print the public key during the SSH step. Add it at:
https://github.com/settings/ssh/new

### Manual steps (both routes)
- Add DHCP reservation in Pi-hole for a static IP
- Enable auto-login in KDE System Settings > Users (for Steam console experience)
- Copy Minecraft world backups to `/opt/bedrock/data/worlds`
- Set monitor refresh rate to max
- Connect Moonlight to `https://localhost:47990` for initial Sunshine pairing

---

## Bazzite

### Standard route

#### 1. Install the OS
[Download Bazzite](https://bazzite.gg/) and do a clean install.

#### 2. Clone and run
```bash
git clone https://github.com/cole-titze/desktop-setup.git
cd desktop-setup
bash bazzite/setup.sh
```

#### 3. Reboot
The PostgreSQL client and CLI tools are installed via `rpm-ostree` and require a reboot to activate. Everything else is available immediately.

```bash
systemctl reboot
```

#### 4. Add SSH key to GitHub
The setup generates `~/.ssh/id_ed25519` and prints the public key. Add it at:
https://github.com/settings/ssh/new

### Agent route

#### 1. Bootstrap Node + Claude Code
```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
source ~/.nvm/nvm.sh
nvm install --lts
curl -fsSL https://claude.ai/install.sh | bash
```

#### 2. Clone the repo and let Claude run the setup
```bash
git clone https://github.com/cole-titze/desktop-setup.git
cd desktop-setup
claude "Run bash bazzite/setup.sh -y to fully set up this Bazzite machine"
```

#### 3. Reboot
```bash
systemctl reboot
```

#### 4. Add SSH key to GitHub
Claude will print the public key during the SSH step. Add it at:
https://github.com/settings/ssh/new

### Manual steps (both routes)
- Copy Minecraft world backups to `/opt/bedrock/data/worlds`
- Verify display output names match your hardware: run `kscreen-doctor -o` and update `OUTPUT_PRIMARY`/`OUTPUT_SECONDARY` in `~/scripts/resolution-toggle.sh` if needed

#### iPad streaming at 4:3 (Sunshine)
To stream at the iPad Pro 13" native resolution (2752×2064), create a virtual display and inject a custom EDID so the NVIDIA driver accepts the resolution.

**Step 1 — create the virtual display:**
```bash
crh
```
1. Choose **Add**
2. Select a **disconnected** port (e.g. `DP-2:disconnected`) — not your physical monitor
3. Resolution: `2752x2064`
4. Refresh rate: `120`
5. Use CVT timing: `Y`
6. Reduced blanking: `Y`
7. Interlaced: `n`
8. Margins: `n`
9. Always enabled: `Y`
10. Enter password and reboot when prompted

> Note: NVIDIA on Wayland ignores the kernel `video=` modedb for virtual displays, so DP-2 will only show 1024×768 after this reboot. The EDID step below is required.

**Step 2 — inject a custom EDID so NVIDIA accepts 2752×2064:**
```bash
crh
```
1. Choose **Add-EDID**
2. Select the same virtual port (`DP-2`)
3. Place your patched EDID binary at `/tmp/crh/edited/edid.bin` before confirming  
   *(crh picks it up automatically from that path)*
4. Enter password and reboot when prompted

The patched EDID must advertise 2752×2064 at 60 Hz (not 120 Hz — the EDID pixel clock field caps at ~655 MHz and 120 Hz requires ~734 MHz). crh installs it to `/usr/local/lib/firmware/edid/edid.bin` and adds these kernel args:
```
firmware_class.path=/usr/local/lib/firmware
drm.edid_firmware=DP-2:edid/edid.bin
video=DP-2:e
```

**Step 3 — point Sunshine at the virtual display:**

In Sunshine's web UI (https://localhost:47990) under **Configuration → Audio/Video**, set **Display Number** to `DP-2`. Or edit directly:
```
~/.var/app/dev.lizardbyte.app.Sunshine/config/sunshine/sunshine.conf
output_name = DP-2
```

**Step 4 — toggle physical monitors off when streaming:**

Click the **iPad Stream (4:3)** shortcut on the Desktop (or run `~/scripts/resolution-toggle.sh`) to disable both physical monitors (DP-1 and HDMI-A-1) so Sunshine captures only the virtual display. Click/run it again to re-enable them.

---

## What gets installed

### Kubuntu
| Step | What |
|------|------|
| 00 | System update + essentials |
| 01 | KDE wallpaper |
| 02 | NVIDIA autostart |
| 03 | Disk config |
| 05 | OS/KDE settings |
| 06 | Claude Code |
| 10 | CLI packages (htop, neovim, jq, etc.) |
| 20 | Steam |
| 25–28 | Steam autostart, Sunshine, Remote Play |
| 30 | .NET 9, nvm/Node LTS, GitHub CLI, sqlpackage |
| 31 | Git config |
| 40–45 | VS Code + settings |
| 50 | Docker |
| 60–66 | Minecraft Bedrock server + systemd + backups |
| 80–85 | SSH keygen + sshd |
| 90 | Cleanup |

### Bazzite
| Step | What |
|------|------|
| 05 | iPad resolution toggle script (`~/scripts/resolution-toggle.sh`) + Desktop shortcut |
| 10 | psql, htop, neovim, jq, etc. (rpm-ostree), gh CLI, .NET 9, sqlpackage, nvm/Node LTS |
| 11 | Git config |
| 12–13 | VS Code (Flatpak) + settings |
| 14 | Claude Code |
| 15 | SSH keygen + enable sshd |
| 20–22 | Minecraft Bedrock server (Podman) + systemd + backups |
