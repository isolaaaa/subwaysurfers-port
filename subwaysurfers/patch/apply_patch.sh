#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
GAME_DIR="${1:-$(cd "$SCRIPT_DIR/.." && pwd -P)}"
PYTHON_BIN="${PYTHON:-python3}"

if ! command -v "$PYTHON_BIN" >/dev/null 2>&1; then
  echo "[patch] python3 is required to apply asset patches." >&2
  exit 1
fi

exec "$PYTHON_BIN" "$SCRIPT_DIR/apply_patch.py" "$GAME_DIR" "$@"
