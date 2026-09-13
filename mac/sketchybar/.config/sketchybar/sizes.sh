#!/usr/bin/env bash
# Sizing presets for SketchyBar.
#
# SketchyBar has ONE global bar — a single height and one font scale shared by
# every display — and every display here runs scaling:off, so a point is a
# physical pixel and apparent size is purely 1/PPI. The panels are far apart:
#
#   Built-in 14"    3024x1964 @1:1   254 PPI   (1800x1169 HiDPI -> 151 PPI)
#   KAMN     40"    5120x2160 @1:1   139 PPI
#   DELL U3425WE 34" 3440x1440 @1:1  110 PPI
#
# No single number serves 254 and 110 (a 2.3x spread), so sizing is per display
# profile. Bar height is anchored to the built-in's reserved menu-bar strip —
# the notch — so the bar exactly fills it and no desktop shows through. That
# strip is physically fixed, so its size in points follows the logical width:
# 64pt at 3024 wide (1:1), 38pt at 1800x1169. Measured, not assumed:
#
#   osascript -l JavaScript -e 'ObjC.import("AppKit");
#     var s = $.NSScreen.screens.objectAtIndex(0), f = s.frame, v = s.visibleFrame;
#     (f.origin.y + f.size.height) - (v.origin.y + v.size.height)'
#
#   dense    laptop only        built-in at 254 PPI            bar 64
#   docked   home, 3 displays   151 / 139 / 110 PPI            bar 38
#
# The preset follows profiles/.current, which plugins/display.sh writes when you
# switch arrangements; display.sh also reloads the bar and re-syncs AeroSpace's
# top gap so the three stay consistent.

SIZES_PROFILE=$(cat "$HOME/.config/sketchybar/profiles/.current" 2>/dev/null)

case "$SIZES_PROFILE" in
  home)                          PRESET=docked ;;
  # Laptop drives these and stays 1:1, so the built-in's 64pt strip rules.
  laptop|present_extend|present_mirror) PRESET=dense ;;
  *)                             PRESET=dense ;;
esac

case "$PRESET" in
  dense)
    BAR_HEIGHT=64
    BAR_PADDING=14
    BUILTIN_RESERVED=64      # built-in at 3024x1964, scaling:off

    ICON_SIZE=26
    LABEL_SIZE=24
    ICON_PAD_L=12
    ICON_PAD_R=6
    LABEL_PAD_L=6
    LABEL_PAD_R=12
    ITEM_PAD=6
    ITEM_BG_HEIGHT=46
    CORNER_RADIUS=8

    SPACE_ICON_SIZE=24
    SPACE_ICON_PAD=10
    SPACE_BG_HEIGHT=34
    APP_ICON_SIZE=24
    APP_PAD=8

    MODE_LABEL_SIZE=22

    STACK_SIZE=15            # the two-line net / sys readouts
    STACK_OFFSET=9
    STACK_PAD=10

    POPUP_PAD=12
    ;;

  docked)
    # Sized up from the 38pt minimum (which matched the built-in's notch strip
    # exactly) so the bar reads at arm's length on the 40" KAMN. The bar is
    # global, so this grows every display: KAMN 6.9 -> 8.0mm, Dell 8.8 ->
    # 10.2mm, built-in 6.4 -> 7.4mm. Above 38 the bar also overhangs the
    # built-in's notch strip; AERO_TOP_BUILTIN below absorbs that.
    BAR_HEIGHT=44
    BAR_PADDING=10
    BUILTIN_RESERVED=38      # built-in at 1800x1169, scaling:on

    ICON_SIZE=17
    LABEL_SIZE=16
    ICON_PAD_L=8
    ICON_PAD_R=5
    LABEL_PAD_L=5
    LABEL_PAD_R=8
    ITEM_PAD=4
    ITEM_BG_HEIGHT=32
    CORNER_RADIUS=6

    SPACE_ICON_SIZE=16
    SPACE_ICON_PAD=7
    SPACE_BG_HEIGHT=24
    APP_ICON_SIZE=16
    APP_PAD=6

    MODE_LABEL_SIZE=15

    STACK_SIZE=12
    STACK_OFFSET=6
    STACK_PAD=7

    POPUP_PAD=8
    ;;
esac

# The stacked items pull their second line back over the first by exactly the
# rendered width of that line: N monospace chars at 0.6 em. net prints 7 chars,
# sys prints a single-width glyph + space + 4-char percent = 6.
NET_OVERLAP=$(awk -v s="$STACK_SIZE" 'BEGIN { printf "%d", 7 * 0.6 * s + 0.5 }')
SYS_OVERLAP=$(awk -v s="$STACK_SIZE" 'BEGIN { printf "%d", 6 * 0.6 * s + 0.5 }')

# AeroSpace tiles inside each monitor's visible frame, so the top gap is the
# part of the bar that macOS has NOT already reserved, plus the aesthetic gap.
AERO_GAP=16
AERO_TOP_BUILTIN=$(( BAR_HEIGHT + AERO_GAP - BUILTIN_RESERVED ))
AERO_TOP_EXTERNAL=$(( BAR_HEIGHT + AERO_GAP ))
