#!/usr/bin/env bash
# ML4W-style application launcher
# Captures the current desktop as a frosted background, then opens rofi.
# The screenshot path must match `current-image` in config.rasi.

set -euo pipefail

SHOT="/tmp/rofi-screenshot.jpg"

# Capture the full desktop (all outputs). JPEG keeps the file small for fast reloads.
if command -v grim >/dev/null 2>&1; then
    grim -t jpeg -q 60 "$SHOT" 2>/dev/null || true
fi

exec rofi -show drun -replace -i
