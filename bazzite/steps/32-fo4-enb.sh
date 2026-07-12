#!/usr/bin/env bash
set -euo pipefail

echo "==> Setting up ENB lighting for Fallout 4 (Bazzite / Linux)"
echo
echo "This step is entirely manual — ENB binaries and the weather/lighting mod"
echo "must be downloaded by hand. This script just prints the steps in order."
echo "Run step 30 (fo4-modding) first if you haven't already."
echo

GAME_DIR="$HOME/.local/share/Steam/steamapps/common/Fallout 4"

echo "============================================================"
echo " MANUAL STEPS REQUIRED"
echo "============================================================"
echo
echo "--- STEP A: Install ENB binaries ---"
echo "1. Go to: http://enbdev.com/download_mod_fallout4.htm"
echo "2. Download the latest ENBSeries version for Fallout 4"
echo "3. Extract ONLY d3d11.dll and d3dcompiler_46e.dll from the archive's"
echo "   WrapperVersion folder directly into:"
echo "   $GAME_DIR/"
echo "   (do NOT route these through LMO — they must sit in the game root,"
echo "   same as the F4SE files from step 30)"
echo
echo "--- STEP B: Install NAC X - Natural and Atmospheric Commonwealth ---"
echo "1. Go to: nexusmods.com/fallout4/mods/46722"
echo "   (NAC X - NATURAL AND ATMOSPHERIC COMMONWEALTH 10 - Legacy Edition)"
echo "2. Download the main file (manual download)"
echo "3. Drag it into LMO, right-click → Deployers → Data, then Deploy"
echo "   (this is the weather/lighting overhaul itself — esp + assets,"
echo "   goes through LMO like any other mod)"
echo
echo "--- STEP C: Install the bundled NAC X ENB preset ---"
echo "1. On the same mod page (nexusmods.com/fallout4/mods/46722), open the"
echo "   Files tab and download NACX_ENB.zip"
echo "2. Extract ALL of its contents directly into:"
echo "   $GAME_DIR/"
echo "   (again, do NOT route this through LMO — ENB config/shader files"
echo "   belong in the game root, not the Data folder)"
echo
echo "--- STEP D: Fix the ENB editor hotkey ---"
echo "NACX_ENB.zip ships an enblocal.ini with the in-game editor bound to the"
echo "End key alone (KeyCombination=0, KeyEditor=35), which doesn't exist on"
echo "compact/tablet keyboards (e.g. iPad Magic Keyboard). Rebind it to the"
echo "classic Shift+Enter combo, which exists on every keyboard:"
echo
echo "   ENBLOCAL_INI=\"$GAME_DIR/enblocal.ini\""
echo "   sed -i 's/^KeyCombination=.*/KeyCombination=16/; s/^KeyEditor=.*/KeyEditor=13/' \"\$ENBLOCAL_INI\""
echo
echo "--- STEP E: Tune the VRAM budget if you also stream via Sunshine/Moonlight ---"
echo "NACX_ENB.zip's enblocal.ini sets VideoMemorySizeMb=8096, as if the card"
echo "had 8GB VRAM. This is just a hint that tells ENB how aggressively to"
echo "cache — not a hard reservation — so raise it to reflect your actual"
echo "card, but leave more headroom than usual if you're also running the"
echo "iPad/Sunshine streaming setup from this README: NVENC hardware encoding"
echo "doesn't compete for GPU shader time, but its buffers do share the same"
echo "VRAM pool. On a 12GB card (e.g. RTX 4070 Ti) at high stream resolution/"
echo "framerate, ~10000 leaves a safer ~2.3GB margin vs. pushing to 11000:"
echo
echo "   sed -i 's/^VideoMemorySizeMb=.*/VideoMemorySizeMb=10000/' \"$GAME_DIR/enblocal.ini\""
echo
echo "--- STEP F: Enable the ENB patch in-game ---"
echo "1. Launch Fallout 4 (see step 30 for the F4SE launch option)"
echo "2. Open your Pip-Boy → Aid (or check your apparel inventory for the"
echo "   NAC X holotape/menu item, depending on version)"
echo "3. Enable the 'Patch for ENB' option from the NAC X menu"
echo "   (NAC X's own weather effects double up with ENB unless this is on)"
echo
echo "--- STEP G: Verify ---"
echo "1. First launch after installing/updating the preset or d3d11.dll will"
echo "   show 'ENBSeries compiling shaders, please wait' — this is normal,"
echo "   not an error, and can take anywhere from seconds to a couple"
echo "   minutes. It's safe to stop the game if it's interrupted; nothing"
echo "   is corrupted, it just recompiles on the next launch. The result is"
echo "   cached in a $GAME_DIR/enbcache/ folder — delete that folder any"
echo "   time you update the preset files or the ENB binary itself, so you"
echo "   get a clean recompile instead of a stale/partial cache:"
echo "     rm -rf \"$GAME_DIR/enbcache\""
echo "2. Once loaded, you should see the ENB logo flash briefly top-left,"
echo "   and Shift+Enter should open the ENBSeries in-game editor overlay"
echo "3. NACX_ENB.zip's enblocal.ini has no EnableLog flag, so the absence of"
echo "   $GAME_DIR/enblog.txt is normal and NOT a sign of failure — a more"
echo "   reliable check is whether enbseries.ini's mtime updates after you"
echo "   play (ENB rewrites it live), e.g.: stat -c %y \"$GAME_DIR/enbseries.ini\""
echo

echo "32-fo4-enb complete"
