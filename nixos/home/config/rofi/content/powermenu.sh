#!/usr/bin/env bash
# ML4W-style power menu
# Captures the current desktop as a frosted background, then shows a dmenu.

set -euo pipefail

SHOT="/tmp/rofi-screenshot.jpg"

options=(
    "󰤄   Sleep"
    "󰒲   Hibernate"
    "󰌾   Lock"
    "󰗽   Logout"
    "󰜉   Reboot"
    "󰐥   Shutdown"
)

if command -v grim >/dev/null 2>&1; then
    grim -t jpeg -q 60 "$SHOT" 2>/dev/null || true
fi

selected=$(printf '%s\n' "${options[@]}" | rofi -dmenu -theme powermenu -p "Power Menu")

case "$selected" in
    *Sleep)
        systemctl suspend
        ;;
    *Hibernate)
        systemctl hibernate
        ;;
    *Lock)
        hyprlock
        ;;
    *Logout)
        hyprctl dispatch exit
        ;;
    *Reboot)
        systemctl reboot
        ;;
    *Shutdown)
        systemctl poweroff
        ;;
esac
