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
To stream at a native 4:3 resolution to an iPad, add a virtual display using Bazzite's `custom-resolution-helper`:

```bash
crh
```

1. Choose **Add**
2. Select your primary display (e.g. `DP-1`)
3. Enter the resolution (e.g. `1920x1440` or `2732x2048` for iPad Pro native)
4. Set refresh to `60`
5. When asked if the display should be **always enabled** — say **yes**
6. Reboot when prompted

After rebooting, configure Sunshine to capture the virtual display. Run `~/scripts/resolution-toggle.sh` to toggle the secondary monitor off/on when switching to iPad mode.

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
| 05 | iPad resolution toggle script (`~/scripts/resolution-toggle.sh`) |
| 10 | psql, htop, neovim, jq, etc. (rpm-ostree), gh CLI, .NET 9, sqlpackage, nvm/Node LTS |
| 11 | Git config |
| 12–13 | VS Code (Flatpak) + settings |
| 14 | Claude Code |
| 15 | SSH keygen + enable sshd |
| 20–22 | Minecraft Bedrock server (Podman) + systemd + backups |
