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
- Verify display output names match your hardware: run `kscreen-doctor -o` and update `OUTPUT_PRIMARY`/`OUTPUT_SECONDARY` in `~/scripts/resolution-toggle.sh` and `~/scripts/iphone-resolution-toggle.sh` if needed
- For iPhone streaming: follow the `crh` EDID injection steps below to create the 2796×1290 virtual display on DP-3
- For Fallout 4 modding: follow the printed instructions from step 30 (GE-Proton, F4SE, LMO, base mods)
- For Skyrim Special Edition modding: follow the printed instructions from step 31 (GE-Proton, SKSE, LMO, base mods)
- For Fallout 4 ENB lighting: follow the printed instructions from step 32 (ENB binaries, NAC X)
- For Skyrim Special Edition ENB lighting: follow the printed instructions from step 33 (ENB binaries, Cathedral Weathers, Rudy ENB SE) — requires Skyrim's compatibility tool set to `GE-Proton9-27` specifically, not GE-Proton Latest, or ENB's shader effects black-screen/crash; see step 33's notes

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

Since Skyrim/Fallout 4 launch via SKSE/F4SE directly (bypassing the Bethesda launcher's resolution picker — see the modding troubleshooting notes), this script also writes the matching resolution (2752x2064 for the iPad, or 2560x1440 for the physical monitor) into both games' prefs INIs each time it toggles, so the games render at the right resolution for whichever display is active without needing a picker.

**Step 5 — separate DP-2 from your primary display:**

KDE places newly-connected outputs at position `(0,0)` by default, same as your primary monitor. Since DP-1 and DP-2 then occupy the same desktop coordinates, DP-2 looks mirrored instead of being an independent extended display. Drag it to an empty area in System Settings → Display Configuration (or `kscreen-doctor output.DP-2.position.<x>,<y>`, e.g. placing it to the right of your rightmost physical monitor). KWin auto-saves the new position to `~/.config/kwinoutputconfig.json`, so this only needs doing once.

#### iPhone streaming at 19.5:9 (Sunshine)
To stream at the iPhone 14 Pro Max native resolution (2796×1290, landscape), create a second virtual display and inject a custom EDID, same as the iPad setup above but on a different port.

**Step 1 — create the virtual display:**
```bash
crh
```
1. Choose **Add**
2. Select a **disconnected** port (e.g. `DP-3:disconnected`) — confirm the exact free port name with `kscreen-doctor -o` first, since `DP-2` is already taken by the iPad virtual display
3. Resolution: `2796x1290`
4. Refresh rate: `120`
5. Use CVT timing: `Y`
6. Reduced blanking: `Y`
7. Interlaced: `n`
8. Margins: `n`
9. Always enabled: `Y`
10. Enter password and reboot when prompted

> Note: same as DP-2, NVIDIA on Wayland ignores the kernel `video=` modedb for virtual displays, so DP-3 will only show 1024×768 after this reboot until the EDID step below is done.

**Step 2 — inject a custom EDID so NVIDIA accepts 2796×1290:**

> **Do NOT use `crh`'s Add-EDID menu option for this second display.** `custom-resolution-helper`'s `addEdid()` always copies the staged file to the single fixed path `/usr/local/lib/firmware/edid/edid.bin` and appends a *separate* `drm.edid_firmware=DP-3:edid/edid.bin` kernel arg rather than merging it with the existing one. `edid_firmware` is a plain kernel **string** parameter (confirm with `modinfo drm | grep edid`) — specifying it twice on the command line means the *last* occurrence wins at boot, not both. Running Add-EDID a second time will overwrite the iPad's EDID file and silently drop DP-2's `drm.edid_firmware` mapping, breaking the already-working iPad display. This has to be done as a manual edit instead, because the driver's single string value supports a **comma-separated list of `connector:file` pairs**, and only a hand edit can combine them.

1. Craft the iPhone EDID: dump a real EDID from a connected physical output (`cat /sys/class/drm/card1-DP-1/edid`) as a template, hand-build an 18-byte Detailed Timing Descriptor for 2796×1290 (CVT-RB-style: fixed `H_FPORCH=48 H_SYNC=32 H_BLANK=160`, vertical blanking derived to hit a clean pixel-clock rounding), and overwrite the template's second descriptor slot (bytes 72–89, the "serial number" descriptor — starts with `00 00 00 FF`) with it, then recompute the base-block checksum (byte 127). This is the same technique the iPad's EDID used.
2. Check the pixel clock with `edid-decode` before it goes anywhere near the system. At 120 Hz, 2796×1290 computes to a ~470 MHz pixel clock — comfortably under the ~655 MHz EDID field cap (unlike the iPad's 2752×2064, which needed ~734 MHz at 120 Hz and had to drop to 60 Hz). Run `edid-decode -c` too and compare its warnings/failures against the *currently deployed* `/usr/local/lib/firmware/edid/edid.bin` — if the same failures appear on both, they're pre-existing artifacts of the template monitor's EDID, not something the edit introduced.
3. Copy the verified binary to a **distinct filename** (not `edid.bin`, which is already the iPad's):
   ```bash
   sudo mkdir -p /usr/local/lib/firmware/edid
   sudo cp <patched-edid> /usr/local/lib/firmware/edid/edid-dp3.bin
   ```
4. Add the new file to the dracut config so it's included in the initramfs, alongside the existing iPad entry — check `/etc/dracut.conf.d/edid.conf` first and add rather than replace:
   ```bash
   echo 'install_items+=" /usr/local/lib/firmware/edid/edid-dp3.bin "' | sudo tee -a /etc/dracut.conf.d/edid.conf
   ```
5. Replace the existing single-connector `drm.edid_firmware` karg with a combined comma-separated one covering both displays, **and** clean up Step 1's stray refresh-rate modeline, all in one atomic `rpm-ostree kargs` call — bundle every delete and append together rather than doing it in two passes, since an intermediate state would either drop the karg entirely or leave the stray modeline fighting the EDID:
   ```bash
   sudo rpm-ostree kargs \
     --delete-if-present="drm.edid_firmware=DP-2:edid/edid.bin" \
     --delete-if-present="video=DP-3:2796x1290MR@120e" \
     --append-if-missing="drm.edid_firmware=DP-2:edid/edid.bin,DP-3:edid/edid-dp3.bin" \
     --append-if-missing="video=DP-3:e"
   ```
6. Run `rpm-ostree kargs` afterward and confirm the output has **exactly one** `drm.edid_firmware=` entry listing both connectors, and `video=DP-2:e video=DP-3:e` with no other `video=DP-3:...` modeline, before rebooting:
   ```bash
   systemctl reboot
   ```

> If you ever need to `crh rm` or `crh remove-all` after this manual edit, be aware its removal logic also assumes the single-`edid.bin`/single-karg model — it won't know about `edid-dp3.bin` or the combined karg. Remove DP-3's entry by hand (adjust the comma-separated `drm.edid_firmware` list, delete `video=DP-3:e`, and `sudo rm /usr/local/lib/firmware/edid/edid-dp3.bin`) rather than running crh's remove flow against it.

**Step 3 — point Sunshine at the virtual display:**

Sunshine only has one global **Display Number** setting — the same one the iPad section above uses. Switching which resolution you stream at means changing this value, not adding a second one. In the web UI (https://localhost:47990) under **Configuration → Audio/Video**, set **Display Number** to `DP-3` when you want to stream to the iPhone (set it back to `DP-2` for the iPad). Or edit directly:
```
~/.var/app/dev.lizardbyte.app.Sunshine/config/sunshine/sunshine.conf
output_name = DP-3
```

**Step 4 — toggle physical monitors off when streaming:**

Click the **iPhone Stream (19.5:9)** shortcut on the Desktop (or run `~/scripts/iphone-resolution-toggle.sh`) to disable both physical monitors so Sunshine captures only the virtual display. Click/run it again to re-enable them. This is a separate script/state file from the iPad's `resolution-toggle.sh`, so the two toggles don't interfere with each other.

Like the iPad toggle, this script also writes the matching resolution (2796x1290 for the iPhone, or 2560x1440 for the physical monitor) into both games' prefs INIs each time it toggles, since Skyrim/Fallout 4 launch via SKSE/F4SE directly and never show the Bethesda launcher's resolution picker.

**Step 5 — check DP-3's position:**

Unlike DP-2, KWin placed DP-3 immediately to the right of DP-2 automatically on first connect (no overlap) rather than defaulting to `(0,0)` — check `kscreen-doctor -o` and confirm its `Geometry` doesn't overlap another output before assuming this step is a no-op. If it does overlap, drag it to an empty area in System Settings → Display Configuration (or `kscreen-doctor output.DP-3.position.<x>,<y>`). KWin auto-saves this to `~/.config/kwinoutputconfig.json`, and `monitors-on-startup.sh` (step `06`) re-asserts a known-good position at every login regardless.

### Troubleshooting: physical monitors go black after setting up a virtual display

KWin remembers a separate saved layout per *set of connected outputs* in `~/.config/kwinoutputconfig.json` (the `"setups"` section). If `resolution-toggle.sh` or `iphone-resolution-toggle.sh` was ever run while the physical monitors plus one or both virtual displays (DP-2, DP-3) were connected, KWin saved that "physical monitors off" layout as the default for that exact combination of outputs — and will silently reapply it on every future boot the instant that same combination is connected, even before the toggle script runs again. This is what causes monitors to go black right after finishing the EDID setup above, and it looks like a driver/EDID bug but isn't. Adding DP-3 means there are now more possible output combinations that can get poisoned this way, not just the DP-1+HDMI-A-1+DP-2 case.

This isn't a one-time fix: KWin overwrites the saved layout with whatever the *live* enabled/disabled state was the last time that exact set of outputs was connected. So every time either toggle script disables the physical monitors for streaming, it re-poisons the saved layout for that combination — and shutting down or rebooting while in that state boots straight back into monitors-off, even if you fixed it once before.

The bootstrap installs `~/scripts/monitors-on-startup.sh` (step `06`) as an XDG autostart entry specifically to work around this: ~8 seconds into every login, it unconditionally force-enables DP-1 and HDMI-A-1, sets DP-1 as primary, and repositions DP-2 and DP-3, regardless of what KWin last saved. This is the actual fix — don't rely on manually re-enabling monitors after each reboot.

If you need to recover immediately without waiting for a login (or the autostart script isn't installed yet):
```bash
export XDG_RUNTIME_DIR="/run/user/$(id -u)"
export WAYLAND_DISPLAY=wayland-0
kscreen-doctor output.DP-1.enable output.HDMI-A-1.enable
```
`.enable`/`.disable`/`.position.`/`.priority.` are safe to run this way. **Never run `kscreen-doctor output.<name>.mode.<resolution>`** — that specific subcommand blacks out the screen on NVIDIA/Wayland regardless of which output it targets.

If the display doesn't come back at all, SSH into the machine from another device (sshd is enabled by default via the bootstrap) and run the same `kscreen-doctor` command — it works headless. Ctrl+Alt+F3 for a TTY is the fallback of last resort.

### Troubleshooting: Sunshine keeps prompting locally for screen/input access, blocking Moonlight

On KDE Wayland, Sunshine (installed as the `dev.lizardbyte.app.Sunshine` flatpak via Bazzite Portal) captures screen and input through `xdg-desktop-portal-kde`'s RemoteDesktop portal. KWin's portal has a known quirk where it re-prompts locally on every session even after you've granted access once and a restore token is stored — so a remote Moonlight client can't connect until someone accepts the dialog on the physical machine.

Step `08` fixes this permanently using Plasma 6.3+'s portal pre-authorization, which skips the dialog outright instead of relying on the restore token:
```bash
flatpak permission-set kde-authorized remote-desktop dev.lizardbyte.app.Sunshine yes
flatpak permission-set kde-authorized screencast dev.lizardbyte.app.Sunshine yes
```
This must run *after* Sunshine is installed via Bazzite Portal (step `08` no-ops if it isn't yet). It's a per-user grant in `~/.local/share/flatpak/db/`, so it survives reboots. GUI equivalent: System Settings → Application Permissions → Sunshine → enable "Remote control."

If prompts still appear after running this, restart the service (`systemctl --user restart app-dev.lizardbyte.app.Sunshine.service`) and check [LizardByte/Sunshine#3953](https://github.com/LizardByte/Sunshine/issues/3953) for a version-specific portal bug.

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
| 07 | iPhone resolution toggle script (`~/scripts/iphone-resolution-toggle.sh`) + Desktop shortcut |
| 08 | Sunshine KDE portal pre-authorization — stops the local accept-screen-share/remote-control prompt from blocking Moonlight connections |
| 10 | psql, htop, neovim, jq, etc. (rpm-ostree), gh CLI, .NET 9, sqlpackage, nvm/Node LTS |
| 11 | Git config |
| 12–13 | VS Code (Flatpak) + settings |
| 14 | Claude Code |
| 15 | SSH keygen + enable sshd |
| 20–22 | Minecraft Bedrock server (Podman) + systemd + backups |
| 30 | Fallout 4 modding — GE-Proton, F4SE, LMO (Linux Mod Organizer), base stability mods |
| 31 | Skyrim Special Edition modding — GE-Proton, SKSE, LMO (Linux Mod Organizer), base stability mods |
| 32 | Fallout 4 ENB lighting — ENB binaries, NAC X (bundled ENB preset) |
| 33 | Skyrim Special Edition ENB lighting — ENB binaries, Cathedral Weathers, Rudy ENB SE (requires GE-Proton9-27, not Latest) |
