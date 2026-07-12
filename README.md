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
- For Fallout 4 modding: follow the printed instructions from step 30 (GE-Proton, F4SE, LMO, base mods)
- For Skyrim Special Edition modding: follow the printed instructions from step 31 (GE-Proton, SKSE, LMO, base mods)
- For Fallout 4 ENB lighting: follow the printed instructions from step 32 (ENB binaries, NAC X)
- For Skyrim Special Edition ENB lighting: follow the printed instructions from step 33 (ENB binaries, Cathedral Weathers, Rudy ENB SE) — note step 33 documents a Proton/DXVK compatibility issue that currently forces ENB's own shader effects off; the weather/shadow/texture mods still work fine on their own

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

> **Check `rpm-ostree kargs` after this step.** Step 1's `video=DP-2:2752x2064MR@120e` (explicit 120 Hz modeline from the "Refresh rate: 120" prompt) can be left behind alongside the bare `video=DP-2:e` from Step 2. If both are present, the stray 120 Hz modeline fights the 60 Hz EDID and NVIDIA rejects the atomic commit for *all* outputs — not just DP-2 — which looks like the whole desktop failing to boot ("Applying output configuration failed!" in the kwin log, or a plain black screen). Remove it if present:
> ```bash
> sudo rpm-ostree kargs --delete="video=DP-2:2752x2064MR@120e"
> ```
> Only `video=DP-2:e` should remain for DP-2.

**Step 3 — point Sunshine at the virtual display:**

In Sunshine's web UI (https://localhost:47990) under **Configuration → Audio/Video**, set **Display Number** to `DP-2`. Or edit directly:
```
~/.var/app/dev.lizardbyte.app.Sunshine/config/sunshine/sunshine.conf
output_name = DP-2
```

**Step 4 — toggle physical monitors off when streaming:**

Click the **iPad Stream (4:3)** shortcut on the Desktop (or run `~/scripts/resolution-toggle.sh`) to disable both physical monitors (DP-1 and HDMI-A-1) so Sunshine captures only the virtual display. Click/run it again to re-enable them.

**Step 5 — separate DP-2 from your primary display:**

KDE places newly-connected outputs at position `(0,0)` by default, same as your primary monitor. Since DP-1 and DP-2 then occupy the same desktop coordinates, DP-2 looks mirrored instead of being an independent extended display. Drag it to an empty area in System Settings → Display Configuration (or `kscreen-doctor output.DP-2.position.<x>,<y>`, e.g. placing it to the right of your rightmost physical monitor). KWin auto-saves the new position to `~/.config/kwinoutputconfig.json`, so this only needs doing once.

### Troubleshooting: physical monitors go black after setting up the virtual display

KWin remembers a separate saved layout per *set of connected outputs* in `~/.config/kwinoutputconfig.json` (the `"setups"` section). If `resolution-toggle.sh` was ever run while DP-1 + HDMI-A-1 + DP-2 were all connected, KWin saved that "physical monitors off" layout as the default for that exact combination of three outputs — and will silently reapply it on every future boot the instant DP-2 becomes connected, even before the toggle script runs again. This is what causes monitors to go black right after finishing the EDID setup above, and it looks like a driver/EDID bug but isn't.

This isn't a one-time fix: KWin overwrites the saved layout with whatever the *live* enabled/disabled state was the last time that exact set of outputs was connected. So every time `resolution-toggle.sh` disables the physical monitors for streaming, it re-poisons the saved layout — and shutting down or rebooting while in that state boots straight back into monitors-off, even if you fixed it once before.

The bootstrap installs `~/scripts/monitors-on-startup.sh` (step `06`) as an XDG autostart entry specifically to work around this: ~8 seconds into every login, it unconditionally force-enables DP-1 and HDMI-A-1, sets DP-1 as primary, and repositions DP-2, regardless of what KWin last saved. This is the actual fix — don't rely on manually re-enabling monitors after each reboot.

If you need to recover immediately without waiting for a login (or the autostart script isn't installed yet):
```bash
export XDG_RUNTIME_DIR="/run/user/$(id -u)"
export WAYLAND_DISPLAY=wayland-0
kscreen-doctor output.DP-1.enable output.HDMI-A-1.enable
```
`.enable`/`.disable`/`.position.`/`.priority.` are safe to run this way. **Never run `kscreen-doctor output.<name>.mode.<resolution>`** — that specific subcommand blacks out the screen on NVIDIA/Wayland regardless of which output it targets.

If the display doesn't come back at all, SSH into the machine from another device (sshd is enabled by default via the bootstrap) and run the same `kscreen-doctor` command — it works headless. Ctrl+Alt+F3 for a TTY is the fallback of last resort.

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
| 06 | Monitors-on-startup autostart script — forces physical monitors back on at every login |
| 10 | psql, htop, neovim, jq, etc. (rpm-ostree), gh CLI, .NET 9, sqlpackage, nvm/Node LTS |
| 11 | Git config |
| 12–13 | VS Code (Flatpak) + settings |
| 14 | Claude Code |
| 15 | SSH keygen + enable sshd |
| 20–22 | Minecraft Bedrock server (Podman) + systemd + backups |
| 30 | Fallout 4 modding — GE-Proton, F4SE, LMO (Linux Mod Organizer), base stability mods |
| 31 | Skyrim Special Edition modding — GE-Proton, SKSE, LMO (Linux Mod Organizer), base stability mods |
| 32 | Fallout 4 ENB lighting — ENB binaries, NAC X (bundled ENB preset) |
| 33 | Skyrim Special Edition ENB lighting — ENB binaries, Cathedral Weathers, Rudy ENB SE (ENB shader effects currently disabled, see step's Known Issue) |
