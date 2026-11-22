#!/usr/bin/env bash
set -euo pipefail

echo "==> Setting KWin custom tile layouts (Shift+drag snap zones)"

# KDE's default custom tile layout is three columns (25/50/25) on every monitor.
# Shift+dragging a window snaps it into these tiles. Override per monitor:
#   DP-1      (main, landscape)   -> two side-by-side halves
#   HDMI-A-1  (vertical/portrait) -> two stacked halves (top/bottom)
#
# Layouts live in ~/.config/kwinrc under [Tiling][<desktop-uuid>][<output-uuid>].
# Both UUIDs are machine-specific, so resolve them at runtime.
# KWin only reads tile layouts at startup: log out and back in to apply.

declare -A LAYOUTS=(
  [DP-1]='{"layoutDirection":"horizontal","tiles":[{"width":0.5},{"width":0.5}]}'
  [HDMI-A-1]='{"layoutDirection":"vertical","tiles":[{"height":0.5},{"height":0.5}]}'
)

DESKTOP_ID=$(kreadconfig6 --file kwinrc --group Desktops --key Id_1)
if [[ -z "$DESKTOP_ID" ]]; then
  echo "No virtual desktop ID in kwinrc yet (log into Plasma once first). Skipping."
  exit 0
fi

# "Output: <n> <connector> <uuid>" lines; strip ANSI colors first.
OUTPUTS=$(kscreen-doctor -o 2>/dev/null | sed 's/\x1b\[[0-9;]*m//g' | awk '/^Output:/ {print $3, $4}')

for connector in "${!LAYOUTS[@]}"; do
  uuid=$(awk -v c="$connector" '$1 == c {print $2}' <<<"$OUTPUTS")
  if [[ -z "$uuid" ]]; then
    echo "  $connector not connected — skipping"
    continue
  fi
  kwriteconfig6 --file kwinrc --group Tiling --group "$DESKTOP_ID" --group "$uuid" \
    --key padding 4
  kwriteconfig6 --file kwinrc --group Tiling --group "$DESKTOP_ID" --group "$uuid" \
    --key tiles "${LAYOUTS[$connector]}"
  echo "  $connector ($uuid) set"
done

echo "09-window-snap-layouts complete"
echo "Log out and back in for KWin to load the new layouts (or edit live with Meta+T)."
echo "Then hold Shift while dragging a window to snap into the halves."
