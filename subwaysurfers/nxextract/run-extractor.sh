#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
GAME_DIR="${NXEXTRACT_GAME_DIR:-$(cd "$SCRIPT_DIR/.." && pwd -P)}"
RECIPE="${NXEXTRACT_RECIPE:-$GAME_DIR/extractor.json}"
PYTHON_BIN="${NXEXTRACT_PYTHON:-python3}"
RUNTIME_HELPER="$SCRIPT_DIR/nxextract-runtime-env.sh"

if [ "${NXEXTRACT_RUNTIME_ENV_ACTIVE:-0}" != 1 ]; then
  [ -f "$RUNTIME_HELPER" ] || {
    printf 'NXExtract: runtime helper is missing: %s\n' \
      "$RUNTIME_HELPER" >&2
    exit 1
  }
  export NXEXTRACT_GAME_DIR="$GAME_DIR"
  # Package extraction must not depend on ZIP tools preserving executable
  # mode bits. Run both shell files explicitly through bash; the helper still
  # creates the isolated child environment before re-entering this launcher.
  exec bash "$RUNTIME_HELPER" bash "$SCRIPT_DIR/run-extractor.sh" "$@"
fi

"$PYTHON_BIN" "$SCRIPT_DIR/nxextract.py" install \
  --recipe "$RECIPE" \
  --game-dir "$GAME_DIR" \
  --ui auto \
  "$@"

# Auto-apply visual patches if patch directory exists
if [ -d "$GAME_DIR/patch" ] && [ ! -f "$GAME_DIR/.patch_applied" ]; then
  if [ -f "$GAME_DIR/patch/apply_patch.sh" ]; then
    bash "$GAME_DIR/patch/apply_patch.sh" "$GAME_DIR" || true
  elif [ -f "$GAME_DIR/patch/apply_patch.py" ]; then
    "$PYTHON_BIN" "$GAME_DIR/patch/apply_patch.py" "$GAME_DIR" || true
  fi
fi
