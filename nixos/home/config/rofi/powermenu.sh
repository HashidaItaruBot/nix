#!/usr/bin/env bash
# Rofi power menu - ml4w style

options=(
    "󰤄   Sleep"
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
