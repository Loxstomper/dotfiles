#!/usr/bin/env bash
# Battery level and charging state.
# Icons are byte-escaped Nerd Font glyphs (decoded by bash at runtime).
source "$HOME/.config/sketchybar/colors.sh"

PERCENTAGE="$(pmset -g batt | grep -Eo '[0-9]+%' | cut -d% -f1)"
CHARGING="$(pmset -g batt | grep 'AC Power')"

[ -z "$PERCENTAGE" ] && exit 0

case "$PERCENTAGE" in
  100|9[0-9]) ICON=$'\xef\x89\x80'; COLOR="$GREEN" ;;   # nf-fa-battery_full
  [6-8][0-9]) ICON=$'\xef\x89\x81'; COLOR="$GREEN" ;;   # nf-fa-battery_three_quarters
  [3-5][0-9]) ICON=$'\xef\x89\x82'; COLOR="$YELLOW" ;;  # nf-fa-battery_half
  [1-2][0-9]) ICON=$'\xef\x89\x83'; COLOR="$ORANGE" ;;  # nf-fa-battery_quarter
  *)          ICON=$'\xef\x89\x84'; COLOR="$RED" ;;     # nf-fa-battery_empty
esac

if [ -n "$CHARGING" ]; then
  ICON=$'\xef\x83\xa7'   # nf-fa-bolt
  COLOR="$CYAN"
fi

sketchybar --set "$NAME" icon="$ICON" icon.color="$COLOR" label="${PERCENTAGE}%"
