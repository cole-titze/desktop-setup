# desktop-setup

Bootstrap scripts for a fresh desktop install. Two setups are available:

| Setup | Folder | OS |
|-------|--------|----|
| Kubuntu | `kubuntu/` | Kubuntu 24.04 LTS — full desktop (KDE, Steam, Sunshine, Docker, Minecraft) |
| Bazzite | `bazzite/` | Bazzite — dev tools + Minecraft only (Steam/gaming is pre-installed on Bazzite) |

---

## Kubuntu

### 1. Install the OS
[Download Kubuntu 24.04 LTS](https://kubuntu.org/getkubuntu/) and do a clean install.

### 2. Clone and run
```bash
sudo apt-get update && sudo apt-get install -y git
git clone https://github.com/cole-titze/desktop-setup.git
cd desktop-setup
bash kubuntu/setup.sh
```

### 3. Add SSH key to GitHub
The setup generates `~/.ssh/id_ed25519` and prints the public key. Add it at:
https://github.com/settings/ssh/new

### 4. Manual steps
- Add DHCP reservation in Pi-hole for a static IP
- Enable auto-login in KDE System Settings > Users (for Steam console experience)
- Copy Minecraft world backups to `/opt/bedrock/data/worlds`
- Set monitor refresh rate to max
- Connect Moonlight to `https://localhost:47990` for initial Sunshine pairing

---

## Bazzite

### 1. Install the OS
[Download Bazzite](https://bazzite.gg/) and do a clean install.

### 2. Clone and run
```bash
git clone https://github.com/cole-titze/desktop-setup.git
cd desktop-setup
bash bazzite/setup.sh
```

### 3. Reboot
The PostgreSQL client (`psql`) is installed via `rpm-ostree` and requires a reboot to activate. Everything else is available immediately.

```bash
systemctl reboot
```

### 4. Add SSH key to GitHub
The setup generates `~/.ssh/id_ed25519` and prints the public key. Add it at:
https://github.com/settings/ssh/new

### 5. Manual steps
- Copy Minecraft world backups to `/opt/bedrock/data/worlds`

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
| 10 | psql (rpm-ostree), gh CLI, .NET 9, sqlpackage, nvm/Node LTS |
| 11 | Git config |
| 12–13 | VS Code (Flatpak) + settings |
| 14 | Claude Code |
| 15 | SSH keygen + enable sshd |
| 20–22 | Minecraft Bedrock server (Podman) + systemd + backups |
