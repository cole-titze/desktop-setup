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

# ---------------------------------------------------------------------------
# 3. Create SKSE launcher wrapper script
# ---------------------------------------------------------------------------
echo "--- Creating SKSE launch wrapper ---"
mkdir -p "$HOME/scripts"
cat > "$HOME/scripts/skyrim_skse_launch.sh" << 'WRAPPER'
#!/bin/bash
# Replaces SkyrimSE.exe with skse64_loader.exe in Steam's Proton launch command
# so that Steam always launches SKSE instead of the base game exe.
GAME_DIR="$HOME/.local/share/Steam/steamapps/common/Skyrim Special Edition"
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
echo "--- STEP D: Check your installed game version ---"
echo "   strings \"\$HOME/.local/share/Steam/steamapps/common/Skyrim Special Edition/SkyrimSE.exe\" | grep -oE '1\\.[0-9]+\\.[0-9]+\\.[0-9]+' | sort -u"
echo "   Steam's current release is the Anniversary Edition build (e.g. 1.6.1170)."
echo "   Only download the matching GOG build if your game folder was installed via GOG."
echo
echo "--- STEP E: Download SKSE64 ---"
echo "1. Go to: https://skse.silverlock.org"
echo "2. Download the 7z matching your game version from Step D (AE build unless you know you're on the older 1.5.97 release)"
echo "3. Extract the archive"
echo "4. Copy skse64_loader.exe and skse64_*.dll to:"
echo "   ~/.local/share/Steam/steamapps/common/Skyrim Special Edition/"
echo "5. Copy the Data/Scripts/ folder to:"
echo "   ~/.local/share/Steam/steamapps/common/Skyrim Special Edition/Data/"
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
echo "  -- Compatibility --"
echo
echo "  1. Address Library for SKSE Plugins (grab both AE and pre-AE file versions)"
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
echo "3. Should show SKSE version (e.g. 2.2.6)"
echo

echo "31-skyrim-modding complete"
