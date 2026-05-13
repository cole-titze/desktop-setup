# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A Kubuntu 24.04 LTS desktop bootstrap. Run once on a fresh install to configure the full environment: KDE Plasma settings, dev tools, Steam/Sunshine for remote gaming, Docker, a Minecraft Bedrock server, and SSH.

## Running the bootstrap

```bash
# Full run (interactive — pauses between steps)
source setup.sh

# Run a single step directly
bash steps/30-dev-base.sh
```

## Architecture

`setup.sh` discovers all `steps/*.sh` files, sorts them by filename, and runs them in order, pausing for confirmation between each. Steps are plain bash with `set -euo pipefail`.

**Step numbering convention:**
- `00–09` — OS prep (apt update, essentials)
- `10–19` — CLI packages
- `20–29` — Gaming layer (Steam, Sunshine/Moonlight)
- `30–39` — Dev toolchain (.NET 9, nvm/Node LTS, GitHub CLI, sqlpackage, Claude Code)
- `40–49` — IDE (VS Code + settings)
- `50–59` — Containers (Docker)
- `60–69` — Services (Minecraft Bedrock server via Docker + systemd + backup hook)
- `80–89` — SSH (keygen, sshd)
- `90–99` — Cleanup

**`files/` directory** holds assets consumed by step scripts:
- `bedrock.service` — systemd unit for the Bedrock Docker container
- `bedrock-backup.conf` — systemd drop-in that triggers `bedrock-backup.sh` on service stop
- `bedrock-backup.sh` — tarballs `/opt/bedrock/data/worlds`, keeps last 15 backups in `/opt/bedrock/backups`
- `bedrock.env` — runtime config for the `itzg/minecraft-bedrock-server` Docker image
- `wallpaper.jpg` — set via `plasma-apply-wallpaperimage` in step 01

## Key conventions

- Steps must be idempotent where practical (check before installing, guard with `command -v` or `dpkg-query`).
- Each step ends with `echo "<NN>-stepname complete"` for clear progress output.
- Steps that install interactive tools (e.g., Claude Code, Steam) print a follow-up instruction rather than attempting automation.
- nvm is installed via the upstream curl script; subsequent `nvm` calls in the same step require sourcing `$NVM_DIR/nvm.sh` and temporarily disabling `set -u`.
- Git identity is hardcoded in `31-gitconfig.sh` (`cole.titze@outlook.com`) — update this when adapting for a new user.

## Post-bootstrap manual steps (from README)

1. Add `~/.ssh/id_ed25519.pub` to GitHub SSH keys
2. Add DHCP reservation in Pi-hole for a static IP
3. Enable auto-login in KDE System Settings > Users for the Steam console experience
4. Copy Minecraft world backups to `/opt/bedrock/data/worlds`
5. Set monitor refresh rate to max
6. Connect Moonlight to `https://localhost:47990` for initial Sunshine pairing
