#!/usr/bin/env bash
# Waybar notification status (dunst)
if dunstctl is-paused 2>/dev/null; then
    echo '{"text":"","class":"dnd-none"}'
else
    echo '{"text":"","class":"notification"}'
fi
