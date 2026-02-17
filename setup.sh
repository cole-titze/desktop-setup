#!/usr/bin/env bash
set -euo pipefail

# Run all step scripts in numeric order.
# Usage:
#   chmod +x setup.sh
#   ./setup.sh

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STEPS_DIR="$ROOT_DIR/steps"

if [[ ! -d "$STEPS_DIR" ]]; then
  echo "ERROR: steps directory not found at: $STEPS_DIR" >&2
  exit 1
fi

echo "==> Running Pop!_OS bootstrap from: $ROOT_DIR"
echo "==> Steps directory: $STEPS_DIR"
echo

shopt -s nullglob
mapfile -t STEPS < <(printf '%s\n' "$STEPS_DIR"/*.sh | sort)
shopt -u nullglob

if [[ "${#STEPS[@]}" -eq 0 ]]; then
  echo "ERROR: No step scripts found in $STEPS_DIR (expected something like 00-system.sh)" >&2
  exit 1
fi

for step in "${STEPS[@]}"; do
  echo "==> Running: $(basename "$step")"
  bash "$step"
  echo
done

echo "All steps completed."
