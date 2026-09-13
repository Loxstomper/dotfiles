#!/usr/bin/env bash
# Solarized Dark — the one place the hex values live.
# Bare RRGGBB so consumers can prefix as they need ("#$SOL_BLUE", "0xff$SOL_BLUE").
# Tools with a built-in Solarized theme (ghostty, bat, nvim) reference it by name;
# tools that take raw hex (sketchybar, borders, tmux, starship) should match these.

export SOL_BASE03=002b36   # darkest background
export SOL_BASE02=073642   # background highlights
export SOL_BASE01=586e75   # comments / secondary content
export SOL_BASE00=657b83
export SOL_BASE0=839496    # primary content
export SOL_BASE1=93a1a1    # emphasised content
export SOL_BASE2=eee8d5
export SOL_BASE3=fdf6e3    # lightest background

export SOL_YELLOW=b58900
export SOL_ORANGE=cb4b16
export SOL_RED=dc322f
export SOL_MAGENTA=d33682
export SOL_VIOLET=6c71c4
export SOL_BLUE=268bd2
export SOL_CYAN=2aa198
export SOL_GREEN=859900
