#!/usr/bin/env bash
set -euo pipefail

echo "==> Setting up Skyrim Special Edition modding (Bazzite / Linux)"
echo
echo "This step mixes automated setup with manual steps that require a browser and GUI."
echo "Automated parts run now; manual instructions are printed as you go."
echo

# ---------------------------------------------------------------------------
# 1. Install Linux Mod Organizer (LMO) via Flatpak
# ---------------------------------------------------------------------------
echo "--- Installing Linux Mod Organizer (LMO) ---"
if flatpak list | grep -q "io.github.limo_app.limo"; then
  echo "LMO already installed, skipping."
else
  flatpak install flathub io.github.limo_app.limo -y
  echo "LMO installed."
fi

# ---------------------------------------------------------------------------
# 2. Grant Flatpak permissions
# ---------------------------------------------------------------------------
echo "--- Granting Flatpak filesystem permissions ---"
flatpak override --user --filesystem="$HOME/.local/share/Steam" com.github.Matoking.protontricks
flatpak override --user --filesystem="$HOME/.local/share/Steam" io.github.limo_app.limo
flatpak override --user --filesystem="$HOME/LIMO" io.github.limo_app.limo
echo "Flatpak permissions set."

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# ---------------------------------------------------------------------------
# 3. Install save-backup script
# ---------------------------------------------------------------------------
# A Steam auto-update (1.6.1170 -> 1.7.104 in Nov 2026) left an existing save
# crashing on load. Dated save backups (tagged with the game version and the
# plugin list) make it possible to roll back instead of losing a playthrough.
# The launch wrapper below runs this automatically before every launch.
echo "--- Installing Skyrim save-backup script ---"
mkdir -p "$HOME/scripts" "$HOME/Backups/Skyrim"
install -m 0755 "$ROOT_DIR/files/skyrim-save-backup.sh" "$HOME/scripts/skyrim-save-backup.sh"
echo "Installed ~/scripts/skyrim-save-backup.sh (backups go to ~/Backups/Skyrim, newest 20 kept)"

# ---------------------------------------------------------------------------
# 4. Create SKSE launcher wrapper script
# ---------------------------------------------------------------------------
echo "--- Creating SKSE launch wrapper ---"
cat > "$HOME/scripts/skyrim_skse_launch.sh" << 'WRAPPER'
#!/bin/bash
# Replaces SkyrimSE.exe with skse64_loader.exe in Steam's Proton launch command
# so that Steam always launches SKSE instead of the base game exe.
# Backs up saves first (non-fatal: a failed backup never blocks the launch).
GAME_DIR="$HOME/.local/share/Steam/steamapps/common/Skyrim Special Edition"
"$HOME/scripts/skyrim-save-backup.sh" > "$HOME/Backups/skyrim-save-backup.log" 2>&1 || true
export SteamDeck=0
exec "${@//"$GAME_DIR/SkyrimSE.exe"/"$GAME_DIR/skse64_loader.exe"}"
WRAPPER
chmod +x "$HOME/scripts/skyrim_skse_launch.sh"
echo "SKSE wrapper created at ~/scripts/skyrim_skse_launch.sh"

echo
echo "============================================================"
echo " MANUAL STEPS REQUIRED"
echo "============================================================"
echo
echo "Complete the following steps in order before running the next step."
echo
echo "--- STEP A: Install GE-Proton ---"
echo "1. Open ProtonPlus from the app menu"
echo "2. Click Install → GE-Proton → Latest → Install"
echo
echo "--- STEP B: Set Skyrim Special Edition to use GE-Proton ---"
echo "1. Open Steam → right-click Skyrim Special Edition → Properties → Compatibility"
echo "2. Check 'Force the use of a specific Steam Play compatibility tool'"
echo "3. Select 'GE-Proton Latest'"
echo
echo "--- STEP B2: Stop Steam from updating Skyrim in the background ---"
echo "Every game update breaks SKSE and most SKSE plugins until their authors"
echo "release new builds (1.7.104 landed silently on 2026-11-14 and broke the"
echo "whole setup). Steam → right-click Skyrim → Properties → Updates →"
echo "'Only update this game when I launch it'. Note this only DEFERS updates"
echo "to launch time, it doesn't prompt — to truly hold a version, launch with"
echo "Steam in Offline mode. Saves are backed up automatically on each launch"
echo "(see ~/scripts/skyrim-save-backup.sh), so a surprise update is recoverable."
echo
echo "--- STEP C: Create the Proton prefix and apply INI tweaks ---"
echo "1. Launch Skyrim Special Edition from Steam (let it reach the main menu)"
echo "2. Close the game"
echo "3. Run the following to enable loose-file mods:"
echo
echo "   CUSTOM_INI=\"\$HOME/.local/share/Steam/steamapps/compatdata/489830/pfx/drive_c/users/steamuser/Documents/My Games/Skyrim Special Edition/SkyrimCustom.ini\""
echo "   mkdir -p \"\$(dirname \"\$CUSTOM_INI\")\""
echo "   if [ ! -f \"\$CUSTOM_INI\" ] || ! grep -q 'bInvalidateOlderFiles' \"\$CUSTOM_INI\"; then"
echo "     printf '[Archive]\\nbInvalidateOlderFiles=1\\nsResourceDataDirsFinal=\\n' >> \"\$CUSTOM_INI\""
echo "   fi"
echo
echo "4. Since we launch via SKSE directly, the vanilla Bethesda launcher never"
echo "   runs — and it's normally what populates SkyrimPrefs.ini's iPresentInterval"
echo "   key. Without it, Skyrim SE's fallback default is vsync ON, silently"
echo "   capping FPS to your display's refresh rate regardless of any Proton/ENB"
echo "   framerate settings. Disable it explicitly:"
echo
echo "   PREFS_INI=\"\$HOME/.local/share/Steam/steamapps/compatdata/489830/pfx/drive_c/users/steamuser/Documents/My Games/Skyrim Special Edition/SkyrimPrefs.ini\""
echo "   if [ -f \"\$PREFS_INI\" ] && ! grep -q 'iPresentInterval' \"\$PREFS_INI\"; then"
echo "     sed -i '/^\\[Display\\]/a iPresentInterval=0' \"\$PREFS_INI\""
echo "   fi"
echo
echo "--- STEP D: Check your installed game version ---"
echo "   strings \"\$HOME/.local/share/Steam/steamapps/common/Skyrim Special Edition/SkyrimSE.exe\" | grep -oE '1\\.[0-9]+\\.[0-9]+\\.[0-9]+' | sort -u"
echo "   Steam's current release is 1.7.104 (since Aug 2026; previously 1.6.1170)."
echo "   Only download the matching GOG build if your game folder was installed via GOG."
echo
echo "--- STEP E: Download SKSE64 ---"
echo "1. Go to: https://skse.silverlock.org — it lists which build matches which"
echo "   game version. As of 1.7.104 (SKSE 2.3.1) the Steam AE build is only"
echo "   hosted on Nexus: nexusmods.com/skyrimspecialedition/mods/30379?tab=files"
echo "2. Download the build matching your game version from Step D (Steam AE, not GOG)"
echo "3. Extract the archive"
echo "4. Copy skse64_loader.exe and skse64_*.dll to:"
echo "   ~/.local/share/Steam/steamapps/common/Skyrim Special Edition/"
echo "   (when updating, delete the old skse64_<oldversion>.dll)"
echo "5. Copy the Data/Scripts/*.pex files into (overwriting):"
echo "   ~/.local/share/Steam/steamapps/common/Skyrim Special Edition/Data/Scripts/"
echo "   Use 'cp --remove-destination' — Data/ is mostly LMO symlinks, and a plain"
echo "   cp onto a symlink writes through into the LMO staging copy instead."
echo
echo "--- STEP F: Set Steam launch options for SKSE ---"
echo "1. Steam → right-click Skyrim Special Edition → Properties → General → Launch Options"
echo "2. Set to: \"$HOME/scripts/skyrim_skse_launch.sh\" %command%"
echo
echo "--- STEP G: Configure LMO ---"
echo "1. Open LMO from the app menu"
echo "2. Click 'New Application' → 'Import from Steam' → select Skyrim Special Edition"
echo "3. Set staging directory to: ~/LIMO/Skyrim"
echo "4. IMPORTANT: verify the 'Bin' and 'Data' deployers were actually created"
echo "   (Application Settings → Deployers). 'Import from Steam' is supposed to"
echo "   auto-create these, but it can silently skip them — if 'Bin' and 'Data'"
echo "   aren't listed, hitting Deploy later will crash LMO with no useful error."
echo "   Add them manually if missing (Case Matching Deployer type):"
echo "     - Data: source ~/LIMO/Skyrim, dest ~/.local/share/Steam/steamapps/common/Skyrim Special Edition/Data"
echo "     - Bin:  source ~/LIMO/Skyrim, dest ~/.local/share/Steam/steamapps/common/Skyrim Special Edition"
echo "5. Manually add a Plugins deployer (Loot Deployer type):"
echo "   - Name: Plugins"
echo "   - Source: ~/.local/share/Steam/steamapps/common/Skyrim Special Edition/Data"
echo "   - Target: ~/.local/share/Steam/steamapps/compatdata/489830/pfx/drive_c/users/steamuser/Local Settings/Application Data/Skyrim Special Edition"
echo "     (this legacy path is a Wine prefix alias for AppData/Local — both resolve to the same place)"
echo "6. Set App launch command to: xdg-open steam://rungameid/489830"
echo
echo "--- STEP H: Install mods via LMO ---"
echo "Download the following from nexusmods.com/skyrimspecialedition (manual download),"
echo "then drag each into LMO, right-click → Deployers → Data, then Deploy."
echo
echo "GOTCHA: some archives wrap everything in an extra top-level data/ (or Data/)"
echo "folder. LMO doesn't strip it, so the mod deploys to Data/data/... where the"
echo "game never looks — silently, no error. This hit 7 mods here (all three"
echo "Skyrim 202X parts, EVLaS, ENB Helper, EVLaS Skyrim Underside, Less"
echo "Distracting Blowing Snow) and went unnoticed for months. After deploying,"
echo "this must print nothing:"
echo "   find \"\$HOME/.local/share/Steam/steamapps/common/Skyrim Special Edition/Data/data\" -type l 2>/dev/null"
echo "If it lists files, flatten the offending staging folder(s) — the number in"
echo "the symlink target is the mod id (LMO must be closed):"
echo "   M=\$HOME/LIMO/Skyrim/<id>; mv \$M/data \$M/.tmp && mv \$M/.tmp/* \$M/ && rmdir \$M/.tmp"
echo "then Deploy again and delete the leftover dead links:"
echo "   find \".../Skyrim Special Edition/Data/data\" -xtype l -delete; find \".../Data/data\" -depth -type d -empty -delete"
echo
echo "  -- Compatibility --"
echo
echo "  1. Address Library for SKSE Plugins — 'All in One' file for your game"
echo "     version (v13 or later for 1.7.104; v11 stops at 1.6.1170)"
echo "     nexusmods.com/skyrimspecialedition/mods/32444"
echo
echo "  -- Bug Fixes --"
echo
echo "  2. Unofficial Skyrim Special Edition Patch (USSEP)"
echo "     nexusmods.com/skyrimspecialedition/mods/266"
echo
echo "  -- UI --"
echo
echo "  3. SkyUI"
echo "     nexusmods.com/skyrimspecialedition/mods/12604"
echo
echo "  -- City overhaul --"
echo
echo "  4. JK's Skyrim"
echo "     nexusmods.com/skyrimspecialedition/mods/6289"
echo
echo "  -- Textures --"
echo
echo "  5. Skyrim 202X (Architecture PART 1, Landscape PART 2, Other PART 3 — all three required)"
echo "     nexusmods.com/skyrimspecialedition/mods/2347"
echo "     No resolution prompt during install — this version ships a fixed mix"
echo "     of 1k/4k/8k textures baked into one download, not separate resolution files."
echo
echo "--- STEP I: Verify ---"
echo "1. Launch Skyrim Special Edition from Steam"
echo "2. Open console with ~ and type: getskseversion"
echo "3. Should show SKSE version (e.g. 2.3.1)"
echo "4. Check which SKSE plugins actually loaded:"
echo "   grep -E 'checking plugin|loaded correctly|recompiled|fatal|disabled' \\"
echo "     \"\$HOME/.local/share/Steam/steamapps/compatdata/489830/pfx/drive_c/users/steamuser/Documents/My Games/Skyrim Special Edition/SKSE/skse64.log\""
echo "   'must be recompiled for new address library' = that plugin has no build"
echo "   for this game version yet; update it or disable it in LMO."
echo
echo "--- After a game update (SKSE/plugins stop loading) ---"
echo "1. Install the new SKSE build + matching Address Library (Steps E and H.1)"
echo "2. Launch, run Step I.4, and update/disable each plugin that fails"
echo "3. Test on a NEW game first — saves made on the old version (or with a"
echo "   different mod list) may crash on load. Restore from ~/Backups/Skyrim if needed."
echo

echo "31-skyrim-modding complete"
