#!/usr/bin/env bash
# Monitor-aware AeroSpace workspace indicators.
#
# Runs once per aerospace_workspace_change / display_change event (driven by the
# hidden `spaces_refresh` item) and repaints all nine workspace items. Each
# workspace is pinned to the SketchyBar display of the monitor that currently
# hosts it (display = the monitor's AppKit NSScreen id, which is what
# `--set <item> display=N` expects). So every monitor's bar shows only its own
# workspaces — the workspace→monitor mapping is visible at a glance.
#
# Each workspace is drawn as two items (created in sketchybarrc):
#   space.N        the bare number  (accent pill when focused; dim when empty)
#   space.N.apps   a chip of small app icons (only when the workspace has windows)
#
# Portability note: macOS only ships bash 3.2, which has no associative arrays.
# Rather than depend on a Homebrew bash, this script sticks to integer-keyed
# indexed arrays (fine in 3.2) and guards every subscript with is_num — see the
# comment on is_num for why an unguarded string subscript is actively dangerous.
export PATH="/opt/homebrew/bin:$PATH"
source "$HOME/.config/sketchybar/colors.sh"
source "$HOME/.config/sketchybar/icon_map.sh"

# The workspaces this bar draws. Indexed arrays below are keyed by these values,
# so they must be integers.
SPACES="1 2 3 4 5 6 7 8 9"

# In bash 3.2 an array subscript is evaluated as an *arithmetic expression*, not
# used as a literal key: "web" resolves as an (unset) variable name and lands on
# index 0, "3x" raises "value too great for base", and "x+5" would quietly write
# to index 5 and clobber workspace 5. Index 0 is never read below, so plain names
# are harmless today — but the behaviour is a coercion quirk, not a guarantee.
# Skipping non-integer keys outright means an unexpected workspace name is simply
# not drawn, rather than landing somewhere unpredictable.
is_num() { case "$1" in '' | *[!0-9]*) return 1 ;; *) return 0 ;; esac; }

# Focused workspaces. AeroSpace can report more than one (e.g. a per-monitor
# focus, or a transient stray), so test membership, not equality — this also
# highlights each monitor's own focused workspace. Held as a space-delimited
# string so no array subscripting is needed at all.
FOC=" "
while IFS= read -r w; do
  [ -n "$w" ] && FOC="$FOC$w "
done < <(aerospace list-workspaces --focused 2>/dev/null)
is_focused() { case "$FOC" in *" $1 "*) return 0 ;; *) return 1 ;; esac; }

# monitor-id → NSScreen id (the SketchyBar display index)
NS=()
while IFS='|' read -r mid ns; do
  is_num "$mid" || continue
  NS[$mid]="$ns"
done < <(aerospace list-monitors --format '%{monitor-id}|%{monitor-appkit-nsscreen-screens-id}' 2>/dev/null)

# workspace → display id, for every workspace homed on each monitor (incl. empty,
# so an owned-but-empty workspace still shows on the right bar)
WSD=()
for mid in "${!NS[@]}"; do
  while IFS= read -r ws; do
    is_num "$ws" || continue
    WSD[$ws]="${NS[$mid]}"
  done < <(aerospace list-workspaces --monitor "$mid" 2>/dev/null)
done

for sid in $SPACES; do
  num="space.$sid"
  apps="space.$sid.apps"
  d="${WSD[$sid]}"

  # Not homed to any connected monitor → hide both items.
  if [ -z "$d" ]; then
    sketchybar --set "$num" drawing=off --set "$apps" drawing=off
    continue
  fi

  # De-duplicated app icons for this workspace.
  icons=""
  while IFS= read -r app; do
    [ -z "$app" ] && continue
    __icon_map "$app"
    icons+="$icon_result"
  done < <(aerospace list-windows --workspace "$sid" --format '%{app-name}' 2>/dev/null | sort -u)

  # Number pill — always visible (so the monitor's range shows), pinned to the
  # hosting display. Accent pill when focused; normal when occupied; dim when empty.
  if is_focused "$sid"; then
    sketchybar --set "$num" display="$d" drawing=on \
      background.drawing=on background.color="$ACCENT_COLOR" icon.color="$BASE3"
  elif [ -n "$icons" ]; then
    sketchybar --set "$num" display="$d" drawing=on \
      background.drawing=off icon.color="$LABEL_COLOR"
  else
    sketchybar --set "$num" display="$d" drawing=on \
      background.drawing=off icon.color="$BASE01"
  fi

  # App-icon chip — only when the workspace has windows; pill only when focused.
  if [ -n "$icons" ]; then
    if is_focused "$sid"; then
      sketchybar --set "$apps" display="$d" drawing=on label="$icons" background.drawing=on
    else
      sketchybar --set "$apps" display="$d" drawing=on label="$icons" background.drawing=off
    fi
  else
    sketchybar --set "$apps" display="$d" drawing=off
  fi
done
