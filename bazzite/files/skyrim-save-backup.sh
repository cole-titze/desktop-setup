#!/usr/bin/env bash
# Backs up Skyrim SE saves + the active plugin list to a dated tarball.
#
# Runs automatically before every launch (called from skyrim_skse_launch.sh),
# and can be run by hand before changing mods, the game version, or Proton:
#   ~/scripts/skyrim-save-backup.sh
#
# Why: a Steam auto-update (e.g. 1.6.1170 -> 1.7.104) or a mod-list change can
# leave existing saves crashing on load. The saves themselves aren't touched,
# but keeping dated copies alongside the plugin list they were made with makes
# it possible to roll back (old game version + matching mods) and load them.
set -euo pipefail

PFX="$HOME/.local/share/Steam/steamapps/compatdata/489830/pfx/drive_c/users/steamuser"
SAVES_DIR="$PFX/Documents/My Games/Skyrim Special Edition/Saves"
PLUGINS_DIR="$PFX/AppData/Local/Skyrim Special Edition"
GAME_EXE="$HOME/.local/share/Steam/steamapps/common/Skyrim Special Edition/SkyrimSE.exe"
BACKUP_DIR="$HOME/Backups/Skyrim"
KEEP=20

[[ -d "$SAVES_DIR" ]] || { echo "No Skyrim saves folder yet, nothing to back up."; exit 0; }
# Skip if there are no actual save files (just steam_autocloud.vdf etc.)
compgen -G "$SAVES_DIR/*.ess" > /dev/null || { echo "No .ess saves found, nothing to back up."; exit 0; }

mkdir -p "$BACKUP_DIR"

# Tag the archive with the game version so you know which build a save needs.
GAME_VER="unknown"
if [[ -f "$GAME_EXE" ]] && command -v strings > /dev/null; then
  GAME_VER="$(strings "$GAME_EXE" | grep -oE '1\.[0-9]+\.[0-9]+\.[0-9]+' | sort -u | tail -1 || true)"
  GAME_VER="${GAME_VER:-unknown}"
fi

TS="$(date +'%Y-%m-%d_%H-%M-%S')"
OUT="$BACKUP_DIR/skyrim-saves_${TS}_v${GAME_VER}.tar.gz"

# Saves, plus plugins.txt/loadorder.txt (the mod list the saves were made with)
EXTRA=()
for f in Plugins.txt plugins.txt loadorder.txt; do
  [[ -f "$PLUGINS_DIR/$f" ]] && EXTRA+=(-C "$PLUGINS_DIR" "$f")
done
tar -czf "$OUT" -C "$(dirname "$SAVES_DIR")" Saves "${EXTRA[@]}"

# Keep the newest $KEEP backups
ls -1t "$BACKUP_DIR"/skyrim-saves_*.tar.gz 2>/dev/null | tail -n +$((KEEP + 1)) | xargs -r rm -f

echo "Skyrim saves backed up to $OUT"
