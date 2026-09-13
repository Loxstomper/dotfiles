#!/usr/bin/env bash
# macOS defaults — captured from a machine set up via System Settings, so
# these are the deltas from stock. Idempotent; most need a logout to apply.
# Check a value:   defaults read <domain> <key>
# Undo one:        defaults delete <domain> <key>
set -uo pipefail

w() { defaults write "$@"; }

echo "→ appearance"
w NSGlobalDomain AppleInterfaceStyle -string "Dark"
w NSGlobalDomain _HIHideMenuBar -bool true              # sketchybar replaces the menu bar

echo "→ keyboard"
w NSGlobalDomain InitialKeyRepeat -int 15               # delay before repeat (stock 25, ×15ms)
w NSGlobalDomain KeyRepeat -int 2                       # repeat interval   (stock 6,  ×15ms)

echo "→ trackpad"
w NSGlobalDomain com.apple.swipescrolldirection -bool false   # natural scrolling off
w NSGlobalDomain com.apple.mouse.tapBehavior -int 1            # tap to click
w com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

echo "→ dock"
w com.apple.dock autohide -bool true
w com.apple.dock tilesize -int 16                       # tiny — aerospace does the work

echo "→ finder"
w com.apple.finder FXPreferredViewStyle -string "Nlsv"  # list view
w com.apple.finder NewWindowTarget -string "PfHm"       # new windows open ~

echo "→ input-source hotkeys off (frees Ctrl+Space / Ctrl+Opt+Space)"
# 60 = select previous input source (ctrl+space), 61 = next (ctrl+opt+space)
w com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 60 \
  '{ enabled = 0; value = { parameters = (32, 49, 262144); type = standard; }; }'
w com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 61 \
  '{ enabled = 0; value = { parameters = (32, 49, 786432); type = standard; }; }'

echo "→ caps lock → escape (built-in keyboard only; external boards remap in firmware)"
# The mapping is stored per keyboard as modifiermapping.<vendor>-<product>-0,
# so detect the built-in keyboard's ids rather than hardcoding this Mac's.
ids=$(hidutil list --matching '{"Built-In":true}' 2>/dev/null \
      | awk '/AppleHIDKeyboardEventDriver/ { print $1, $2; exit }')
if [ -n "$ids" ]; then
  vid=$(( $(echo "$ids" | cut -d' ' -f1) ))
  pid=$(( $(echo "$ids" | cut -d' ' -f2) ))
  # Src 0x700000039 = Caps Lock, Dst 0x700000029 = Escape
  defaults -currentHost write NSGlobalDomain \
    "com.apple.keyboard.modifiermapping.${vid}-${pid}-0" -array \
    '{ HIDKeyboardModifierMappingSrc = 30064771129; HIDKeyboardModifierMappingDst = 30064771113; }'
  echo "  mapped for keyboard ${vid}-${pid}"
else
  echo "  ! could not detect built-in keyboard — set it in System Settings → Keyboard → Modifier Keys" >&2
fi

echo "→ restarting Dock, Finder, SystemUIServer"
killall Dock Finder SystemUIServer 2>/dev/null || true
echo "Done. Log out and back in for keyboard and menu bar changes."
