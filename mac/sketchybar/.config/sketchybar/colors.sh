#!/usr/bin/env bash
# Solarized Dark palette — format 0xAARRGGBB. Hex values come from the shared
# theme file so every shell-based config agrees.
source "$HOME/.config/theme/solarized-dark.sh"

# Base tones
export BASE03=0xff$SOL_BASE03   # background
export BASE02=0xff$SOL_BASE02   # background highlights
export BASE01=0xff$SOL_BASE01   # secondary / inactive content
export BASE00=0xff$SOL_BASE00
export BASE0=0xff$SOL_BASE0     # primary content
export BASE1=0xff$SOL_BASE1     # emphasized content
export BASE2=0xff$SOL_BASE2
export BASE3=0xff$SOL_BASE3

# Accents
export YELLOW=0xff$SOL_YELLOW
export ORANGE=0xff$SOL_ORANGE
export RED=0xff$SOL_RED
export MAGENTA=0xff$SOL_MAGENTA
export VIOLET=0xff$SOL_VIOLET
export BLUE=0xff$SOL_BLUE
export CYAN=0xff$SOL_CYAN
export GREEN=0xff$SOL_GREEN

# Semantic roles
export BAR_COLOR=0xf0$SOL_BASE03
export ITEM_BG_COLOR=0xff$SOL_BASE02
export ACCENT_COLOR=$BLUE
export LABEL_COLOR=$BASE0
export ICON_COLOR=$BASE1
export TRANSPARENT=0x00000000
