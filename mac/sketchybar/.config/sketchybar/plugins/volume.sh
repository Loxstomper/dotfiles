#!/usr/bin/env bash
# System output volume.
# Icons are byte-escaped Nerd Font glyphs (decoded by bash at runtime).
source "$HOME/.config/sketchybar/colors.sh"

# INFO carries the new percentage, but only on volume_change — other senders
# (system_woke, display_change) put their own payload there.
if [ "$SENDER" = "volume_change" ] && [ -n "$INFO" ]; then
  VOLUME="$INFO"
else
  VOLUME=$(osascript -e 'output volume of (get volume settings)' 2>/dev/null)
fi

# A display connected over DisplayPort/HDMI delegates volume to the panel, so
# CoreAudio exposes no software volume and AppleScript answers "missing value".
# Say where the sound is going rather than printing a bogus percentage.
if [ -z "$VOLUME" ] || [ -n "${VOLUME//[0-9]/}" ]; then
  sketchybar --set "$NAME" \
    icon=$'\xef\x84\x88' \
    icon.color="$BASE01" \
    label="—" \
    label.color="$BASE01"
  exit 0
fi

case "$VOLUME" in
  [6-9][0-9]|100)   ICON=$'\xef\x80\xa8' ;;   # nf-fa-volume_up
  [3-5][0-9])       ICON=$'\xef\x80\xa7' ;;   # nf-fa-volume_down
  [1-9]|[1-2][0-9]) ICON=$'\xef\x80\xa7' ;;   # nf-fa-volume_down
  *)                ICON=$'\xef\x80\xa6' ;;   # nf-fa-volume_off
esac

# Colours are reset explicitly: the no-software-volume branch above dims them
# and they persist on the item until something sets them back.
sketchybar --set "$NAME" \
  icon="$ICON" \
  icon.color="$CYAN" \
  label="${VOLUME}%" \
  label.color="$LABEL_COLOR"
