#!/usr/bin/env bash
set -euo pipefail

echo "==> Setting up Fallout 4 modding (Bazzite / Linux)"
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
# 3. Create F4SE launcher wrapper script
# ---------------------------------------------------------------------------
echo "--- Creating F4SE launch wrapper ---"
mkdir -p "$HOME/scripts"
GAME_DIR="$HOME/.local/share/Steam/steamapps/common/Fallout 4"
cat > "$HOME/scripts/fo4_f4se_launch.sh" << 'WRAPPER'
#!/bin/bash
# Replaces Fallout4.exe with f4se_loader.exe in Steam's Proton launch command
# so that Steam always launches F4SE instead of the base game exe.
GAME_DIR="$HOME/.local/share/Steam/steamapps/common/Fallout 4"
export SteamDeck=0
exec "${@//"$GAME_DIR/Fallout4.exe"/"$GAME_DIR/f4se_loader.exe"}"
WRAPPER
chmod +x "$HOME/scripts/fo4_f4se_launch.sh"
echo "F4SE wrapper created at ~/scripts/fo4_f4se_launch.sh"

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
echo "--- STEP B: Set Fallout 4 to use GE-Proton ---"
echo "1. Open Steam → right-click Fallout 4 → Properties → Compatibility"
echo "2. Check 'Force the use of a specific Steam Play compatibility tool'"
echo "3. Select 'GE-Proton Latest'"
echo
echo "--- STEP C: Create the Proton prefix and apply INI tweaks ---"
echo "1. Launch Fallout 4 from Steam (let it reach the main menu)"
echo "2. Close the game"
echo "3. Run the following to enable loose-file mods:"
echo
echo "   CUSTOM_INI=\"\$HOME/.local/share/Steam/steamapps/compatdata/377160/pfx/drive_c/users/steamuser/Documents/My Games/Fallout4/Fallout4Custom.ini\""
echo "   if ! grep -q 'bInvalidateOlderFiles' \"\$CUSTOM_INI\"; then"
echo "     sed -i '1s/^/[Archive]\\nbInvalidateOlderFiles=1\\nsResourceDataDirsFinal=\\n\\n/' \"\$CUSTOM_INI\""
echo "   fi"
echo
echo "--- STEP D: Download F4SE ---"
echo "1. Go to: https://f4se.silverlock.org"
echo "2. Download the version matching your game runtime (check in Steam → Fallout 4 → Properties for version)"
echo "3. Extract the archive"
echo "4. Copy f4se_loader.exe and f4se_*.dll to:"
echo "   ~/.local/share/Steam/steamapps/common/Fallout 4/"
echo "5. Copy the Data/Scripts/ folder to:"
echo "   ~/.local/share/Steam/steamapps/common/Fallout 4/Data/"
echo
echo "--- STEP E: Set Steam launch options for F4SE ---"
echo "1. Steam → right-click Fallout 4 → Properties → General → Launch Options"
echo "2. Set to: \"$HOME/scripts/fo4_f4se_launch.sh\" %command%"
echo
echo "--- STEP F: Configure LMO ---"
echo "1. Open LMO from the app menu"
echo "2. Click 'New Application' → 'Import from Steam' → select Fallout 4"
echo "3. Set staging directory to: ~/LIMO/Fallout4"
echo "4. Manually add a Plugins deployer (Loot Deployer type):"
echo "   - Name: Plugins"
echo "   - Source: ~/.local/share/Steam/steamapps/common/Fallout 4/Data"
echo "   - Target: ~/.local/share/Steam/steamapps/compatdata/377160/pfx/drive_c/users/steamuser/AppData/Local/Fallout4"
echo "5. Set App launch command to: xdg-open steam://rungameid/377160"
echo
echo "--- STEP G: Install mods via LMO ---"
echo "Download the following from nexusmods.com/fallout4 (manual download),"
echo "then drag each into LMO, right-click → Deployers → Data, then Deploy."
echo
echo "  -- Stability / Performance --"
echo
echo "  1. Address Library for F4SE Plugins (All In One)"
echo "     nexusmods.com/fallout4/mods/47327"
echo
echo "  2. Addictol (main file + Crash Logger — pick your game version)"
echo "     nexusmods.com/fallout4/mods/102068"
echo "     (Replaces Buffout 4, X-Cell, Mentats, and more)"
echo
echo "  3. High FPS Physics Fix"
echo "     nexusmods.com/fallout4/mods/44798"
echo "     (Decouples physics engine from framerate — required for 60fps+)"
echo
echo "  -- Bug Fixes --"
echo
echo "  4. Unofficial Fallout 4 Patch (main file + UFO4P Creations Bundle Patches)"
echo "     nexusmods.com/fallout4/mods/4598"
echo "     (Select all compatibility patches in the FOMOD installer)"
echo
echo "  -- UI --"
echo
echo "  5. Mod Configuration Menu (MCM) — pick version matching your game runtime"
echo "     nexusmods.com/fallout4/mods/21497"
echo
echo "  -- Textures --"
echo
echo "  6. Vivid Fallout - All in One (4K version)"
echo "     nexusmods.com/fallout4/mods/25714"
echo
echo "  7. Vivid Fallout - LOD and Far Distant Detail (Commonwealth)"
echo "     nexusmods.com/fallout4/mods/71745"
echo
echo "  8. Vivid Fallout LOD - Far Harbor (if you own Far Harbor DLC)"
echo "     nexusmods.com/fallout4/mods/71976"
echo
echo "  9. Vivid Fallout LOD - Nuka World (if you own Nuka-World DLC)"
echo "     nexusmods.com/fallout4/mods/72024"
echo
echo "--- STEP H: Verify ---"
echo "1. Launch Fallout 4 from Steam"
echo "2. Open console with ~ and type: getf4seversion"
echo "3. Should show F4SE version (e.g. 0.7.8)"
echo

echo "30-fo4-modding complete"
