#!/usr/bin/env bash
# ML4W-style power menu
# Glass-morphism: Hyprland blur shows through the semi-transparent rofi window.

set -euo pipefail

options=(
    "󰤄   Sleep"
    "󰒲   Hibernate"
    "󰌾   Lock"
    "󰗽   Logout"
    "󰜉   Reboot"
    "󰐥   Shutdown"
)

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
