#!/usr/bin/env bash
# AeroSpace mode indicator — only visible when not in the default 'main' mode.
source "$HOME/.config/sketchybar/colors.sh"

if [ "$MODE" = "service" ]; then
  sketchybar --set "$NAME" drawing=on label="SERVICE"
else
  sketchybar --set "$NAME" drawing=off
fi
