# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

Desktop bootstrap scripts for two setups:
- **`kubuntu/`** — Kubuntu 24.04 LTS full desktop: KDE Plasma settings, dev tools, Steam/Sunshine for remote gaming, Docker, Minecraft Bedrock server, SSH
- **`bazzite/`** — Bazzite (Fedora-based immutable OS): dev tools + Minecraft only (Steam/gaming is pre-installed on Bazzite)

## Running the bootstrap

```bash
# Kubuntu — full run (interactive)
bash kubuntu/setup.sh

# Bazzite — full run (interactive)
bash bazzite/setup.sh

# Run a single step directly
bash bazzite/steps/05-resolution-toggle.sh
```

## Architecture

Each `setup.sh` discovers all `steps/*.sh` files, sorts them by filename, and runs them in order, pausing for confirmation between each. Steps are plain bash with `set -euo pipefail`.

**Kubuntu step numbering:**
- `00–09` — OS prep (apt update, essentials)
- `10–19` — CLI packages
- `20–29` — Gaming layer (Steam, Sunshine/Moonlight)
- `30–39` — Dev toolchain (.NET 9, nvm/Node LTS, GitHub CLI, sqlpackage, Claude Code)
- `40–49` — IDE (VS Code + settings)
- `50–59` — Containers (Docker)
- `60–69` — Services (Minecraft Bedrock server via Docker + systemd + backup hook)
- `80–89` — SSH (keygen, sshd)
- `90–99` — Cleanup

**Bazzite step numbering:**
- `05` — iPad resolution toggle script + Desktop shortcut
- `06` — Monitors-on-startup autostart script (forces physical monitors back on at every login)
- `07` — iPhone virtual-display toggle script + Desktop shortcut (mirrors 05, separate state file)
- `08` — Sunshine KDE portal pre-authorization (remote-desktop + screencast) so Moonlight can connect without a local accept prompt each session
- `09` — KWin custom tile layouts (Shift+drag snap zones): DP-1 two side-by-side halves, vertical HDMI-A-1 two stacked halves
- `10–15` — Dev toolchain (rpm-ostree CLI tools, gh, .NET, nvm/Node, VS Code, Claude Code, SSH)
- `20–22` — Minecraft Bedrock server (Podman) + systemd + backup hook

**`kubuntu/files/` directory:**
- `bedrock.service` — systemd unit for the Bedrock Docker container
- `bedrock-backup.conf` — systemd drop-in that triggers `bedrock-backup.sh` on service stop
- `bedrock-backup.sh` — tarballs `/opt/bedrock/data/worlds`, keeps last 15 backups in `/opt/bedrock/backups`
- `bedrock.env` — runtime config for the `itzg/minecraft-bedrock-server` Docker image
- `wallpaper.jpg` — set via `plasma-apply-wallpaperimage` in step 01

**`bazzite/files/` directory:**
- `resolution-toggle.sh` — toggles DP-1 and HDMI-A-1 on/off for iPad Sunshine streaming; also writes `iSize W`/`iSize H` into `SkyrimPrefs.ini` and `Fallout4Prefs.ini` (2752x2064 entering iPad-stream mode, 2560x1440 — DP-1 native — restoring physical monitors), since SKSE/F4SE bypass the Bethesda launcher's resolution picker entirely (see below); installed to `~/scripts/`
- `resolution-toggle.desktop` — KDE desktop shortcut for the toggle script; installed to `~/Desktop/` and trusted via `gio`
- `iphone-resolution-toggle.sh` — same toggle pattern as `resolution-toggle.sh` but for iPhone Sunshine streaming (DP-3), including the same game-resolution sync (2796x1290 entering iPhone-stream mode); uses its own state file (`/tmp/iphone-stream-mode`) so it can be run independently of the iPad toggle; installed to `~/scripts/`
- `iphone-resolution-toggle.desktop` — KDE desktop shortcut for the iPhone toggle script; installed to `~/Desktop/` and trusted via `gio`
- `monitors-on-startup.sh` — force-enables DP-1/HDMI-A-1, fixes DP-1 as primary, and repositions both DP-2 (iPad) and DP-3 (iPhone) virtual displays at every login; installed to `~/scripts/`
- `monitors-on-startup.desktop` — XDG autostart entry for the above; installed to `~/.config/autostart/`
- `bedrock.service`, `bedrock-backup.conf`, `bedrock-backup.sh`, `bedrock.env` — same Minecraft assets as Kubuntu but for Podman
- `skyrim-save-backup.sh` — tarballs Skyrim SE's Saves folder plus `Plugins.txt`/`loadorder.txt` into `~/Backups/Skyrim/skyrim-saves_<timestamp>_v<gameversion>.tar.gz`, keeps the newest 20; installed to `~/scripts/` by step `31` and called (non-fatally) at the top of `skyrim_skse_launch.sh` so every launch is backed up
- `dds-downscale.py` — makes a downscaled copy of a texture mod (e.g. 4K/8K → 2K) by dropping the top mip levels of large DDS files (no re-encode; hardlinks everything else; sources untouched); installed to `~/scripts/` by step `31` and used for the Skyrim 202X 2K copy (step 31, H.5)
- `generate-displayid-edid.mjs` — self-contained (no npm deps) Node script that builds a virtual-display EDID with a DisplayID 1.3 Type I timing for resolution/refresh combos whose pixel clock exceeds the base EDID DTD's 655.35 MHz field limit (e.g. the iPad Pro's 2752×2064@120Hz, ~763 MHz); see the iPad streaming section in the README

## Key conventions

- Steps must be idempotent where practical (check before installing, guard with `command -v` or `rpm -q`).
- Each step ends with `echo "<NN>-stepname complete"` for clear progress output.
- Steps that install interactive tools (e.g., Claude Code) print a follow-up instruction rather than attempting automation.
- nvm is installed via the upstream curl script; subsequent `nvm` calls in the same step require sourcing `$NVM_DIR/nvm.sh` and temporarily disabling `set -u`.
- Git identity is hardcoded in `11-gitconfig.sh` (Bazzite) / `31-gitconfig.sh` (Kubuntu) — update when adapting for a new user.
- On Bazzite, never run `kscreen-doctor output.<name>.mode.<resolution>` — it blacks out the screen on NVIDIA/Wayland. `.enable`/`.disable`/`.position.`/`.priority.` are safe. Give the `.mode.` command to the user to run themselves.
- `kscreen-doctor output.<name>.priority.<n>` sets which output is primary (lower number = higher priority, `1` = primary). It must be its own `kscreen-doctor` invocation, separate from any `.enable` in the same batch — KWin re-derives priority as part of enabling an output and silently overwrites a priority passed in the same atomic call. See `resolution-toggle.sh`.
- On Bazzite, `sudo rpm-ostree kargs` cannot be run through Claude Code's Bash tool — it needs a real TTY for the password. Give the exact command to the user to run at their own terminal.
- `~/.config/kwinoutputconfig.json`'s `"setups"` section persists a separate enabled/disabled layout per unique set of connected outputs. If physical monitors were ever disabled (e.g. via `resolution-toggle.sh`) while the DP-2 virtual display was connected, KWin saves that as the default for "these outputs connected" and silently reapplies it — including disabling physical monitors — on every future boot where DP-2 is connected, independent of whether the toggle script actually ran. See the iPad-streaming troubleshooting section in the README.
- This saved layout isn't a one-time gotcha to fix and forget: KWin overwrites it with whatever the *live* enabled/disabled state was the last time that exact set of outputs was connected. So every `resolution-toggle.sh` run that disables the physical monitors re-poisons the saved layout, and shutting down/rebooting while in that state boots back into monitors-off. `monitors-on-startup.sh` (installed by step `06`, autostarted via `~/.config/autostart/`) works around this by unconditionally forcing the physical monitors back on ~8s into every login, rather than trying to fix the saved layout itself.
- Sunshine on Bazzite is installed via Bazzite Portal as the flatpak `dev.lizardbyte.app.Sunshine` (not scripted here — GUI-only install), running as the systemd user service `app-dev.lizardbyte.app.Sunshine.service`. On KDE Wayland it captures screen/input through `xdg-desktop-portal-kde`'s RemoteDesktop portal, which re-prompts locally on every session even after a stored restore token exists — a known KWin portal quirk, not a one-off misclick. `flatpak permission-set kde-authorized <remote-desktop|screencast> dev.lizardbyte.app.Sunshine yes` (Plasma 6.3+'s pre-authorization mechanism, step `08`) skips the dialog outright instead of relying on the restore token. GUI equivalent: System Settings → Application Permissions → Sunshine → Remote control.
- `crh`'s (`/usr/bin/custom-resolution-helper`) Add-EDID flow only supports **one** custom EDID system-wide: it always writes the staged file to the fixed path `/usr/local/lib/firmware/edid/edid.bin` and appends a standalone `drm.edid_firmware=<connector>:edid/edid.bin` karg. `edid_firmware` is a plain kernel string parameter (`modinfo drm | grep edid`), so a second `drm.edid_firmware=` karg for a second connector doesn't merge with the first — the last one wins at boot, silently dropping the earlier connector's EDID. Adding a second virtual display's EDID (e.g. DP-3 alongside the existing DP-2 iPad EDID) must be done by hand: copy the new EDID to a distinct filename, add it to `/etc/dracut.conf.d/edid.conf`, and replace the single-connector karg with one combined comma-separated value (`drm.edid_firmware=DP-2:edid/edid.bin,DP-3:edid/edid-dp3.bin` — note the `edid/` prefix is required for both entries, since it's relative to `firmware_class.path=/usr/local/lib/firmware`) in a single `rpm-ostree kargs` call — never run `crh add-edid` again once more than one virtual display's EDID is in play. See the iPhone streaming section in the README for the full manual procedure.
- The base EDID Detailed Timing Descriptor's pixel clock field is 2 bytes in 10 kHz units — hard-capped at 655.35 MHz regardless of which monitor's EDID is used as a donor/template (this is a structural EDID format limit, not a property of any specific display). A **DisplayID extension block** is the only way past it (3-byte pixel clock field). But DisplayID *version* support is GPU/driver-dependent and not predictable from the spec: on an RTX 4070 Ti with NVIDIA driver 610.43.03, DisplayID 2.0 (Type VII timing) was read successfully by the kernel (visible via `edid-decode` against `/sys/class/drm/cardN-<connector>/edid`) but the driver never added the mode to the connector's KMS mode list — no error logged either way. DisplayID **1.3** (Type I timing — same 20-byte layout, just an older section header) worked immediately. If a DisplayID-based mode doesn't show up in `kscreen-doctor -o` after a reboot, that's the first thing to try switching, not necessarily a malformed EDID. See `generate-displayid-edid.mjs` and the iPad streaming section in the README.
- The custom EDID for a virtual display (`drm.edid_firmware=<connector>:edid/<file>` karg) is **not** baked into the initramfs by dracut/rpm-ostree despite the `/etc/dracut.conf.d/edid.conf` `install_items` entry — confirmed via `lsinitrd` showing no `edid` files present. The kernel's first firmware-load attempt for it fails early in boot (`Direct firmware load for edid/... failed with error -2`, logged every boot, harmless) because `/usr/local` (the `firmware_class.path=`) isn't mounted yet at that point; a later retry against the live, persistent file succeeds silently before the desktop session starts. This means editing `/usr/local/lib/firmware/edid/edid.bin` directly and rebooting is sufficient to pick up changes — no `rpm-ostree kargs`/initramfs rebuild dance is needed unless a *karg value itself* is changing (e.g. adding a new connector's `drm.edid_firmware` entry).
- KWin custom tile layouts (Shift+drag snap zones) live in `~/.config/kwinrc` under `[Tiling][<virtual-desktop-uuid>][<output-uuid>]`. Both UUIDs are machine-specific: the desktop ID is `[Desktops] Id_1`, and the output UUID is the 4th field of `kscreen-doctor -o`'s `Output:` line (`kscreen-doctor -j` does **not** include it). KWin only reads these at startup — `org.kde.KWin.reconfigure` doesn't reload them — so a config change needs a logout/login, or use the live Meta+T editor. Vertical layouts use `"height"` per child tile, horizontal use `"width"`. Edge-drag quick tiling (left/right halves, corner quarters, top = maximize) is fixed and ignores monitor orientation; Meta+Up/Down quick-tiles top/bottom. See step `09`.
- Skyrim SE and Fallout 4 are launched via SKSE/F4SE wrapper scripts (`~/scripts/skyrim_skse_launch.sh`, `~/scripts/fo4_f4se_launch.sh`, generated by steps `31`/`30`) that point Steam's launch options directly at `skse64_loader.exe`/`f4se_loader.exe`. This bypasses the vanilla Bethesda launcher exe entirely, so its resolution/quality picker window can never show (it only ever appeared once, before the wrapper was wired up) — `SteamDeck=0` and other handheld-detection workarounds do not fix this, since the launcher isn't being skipped by detection, it's never invoked at all. Since there's no picker to change resolution through, `resolution-toggle.sh`/`iphone-resolution-toggle.sh` instead write `iSize W`/`iSize H` directly into `SkyrimPrefs.ini`/`Fallout4Prefs.ini` to match whichever display just became active.

- LMO (Linux Mod Organizer) does not strip a top-level `data/`/`Data/` wrapper folder from mod archives, so those mods deploy to `<game>/Data/data/...` and silently never load. Check with `find "<game>/Data/data" -type l` (should be empty) after any install; flatten the staging folder (`~/LIMO/Skyrim/<id>/`) with LMO closed, redeploy, then delete the dead links LMO leaves behind (`find … -xtype l -delete`). See step `31`.
- LMO's Data deployer uses symlinks into `~/LIMO/<game>/`. Never `cp` onto a path under the game's `Data/` without checking for a symlink first (or use `cp --remove-destination`) — a plain `cp` writes through into the staging copy.
- After a Skyrim game update, the SKSE log (`.../My Games/Skyrim Special Edition/SKSE/skse64.log`) is the source of truth for which plugins load: `must be recompiled for new address library` = no build for this game version yet; `fatal error occurred while loading plugin` = the plugin threw during load. A hang with no log line after `attempting to load` in `<game>/d3dx9_42.log` is SSE Engine Fixes' preloader.

## Post-bootstrap manual steps

**Kubuntu:**
1. Add `~/.ssh/id_ed25519.pub` to GitHub SSH keys
2. Add DHCP reservation in Pi-hole for a static IP
3. Enable auto-login in KDE System Settings > Users (Steam console experience)
4. Copy Minecraft world backups to `/opt/bedrock/data/worlds`
5. Set monitor refresh rate to max
6. Connect Moonlight to `https://localhost:47990` for initial Sunshine pairing

**Bazzite:**
1. Add `~/.ssh/id_ed25519.pub` to GitHub SSH keys
2. Copy Minecraft world backups to `/opt/bedrock/data/worlds`
3. Verify display output names: `kscreen-doctor -o` — update `OUTPUT_PRIMARY`/`OUTPUT_SECONDARY` in `~/scripts/resolution-toggle.sh` if needed
4. For iPad streaming: follow the `crh` EDID injection steps in README to create the 2752×2064 virtual display on DP-2
