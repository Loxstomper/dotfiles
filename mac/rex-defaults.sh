#!/usr/bin/env bash
# Rex app settings — the parts init.lua can't hold (theme, font). Rex keeps
# these in its preferences, so they're written with `defaults`. Rex must be
# quit first or it overwrites them from memory on exit.
# Check a value:   defaults read com.superlogical.rex Workspace.<key>
# Re-capture the theme after changing it in Rex:
#   defaults export com.superlogical.rex - > /tmp/rex.plist && python3 -I -c 'import plistlib,json,sys; \
#     json.dump(json.loads(plistlib.load(open(sys.argv[1],"rb"))["Workspace.customThemes"]), open(sys.argv[2],"w"), indent=2)' \
#     /tmp/rex.plist mac/rex-theme.json
set -uo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
D=com.superlogical.rex

if pgrep -xq Rex; then
  echo "  ! Rex is running — quit it (cmd+q) and run: bash $DIR/rex-defaults.sh" >&2
  exit 1
fi

w() { defaults write "$D" "Workspace.$1" "${@:2}"; }

echo "→ font"
w terminalFontName -string "JetBrainsMono Nerd Font Mono"
w terminalFontPointSize -int 26

echo "→ theme (Solarized Dark Patched, imported from Ghostty)"
# Stored as JSON in a data blob; the id must match darkThemeID
w customThemes -data "$(python3 -I -c 'import json,sys; print(json.dumps(json.load(open(sys.argv[1])), separators=(",", ":")), end="")' "$DIR/rex-theme.json" | xxd -p | tr -d '\n')"
w darkThemeID -string "custom-6AD6DA1F-563F-4307-9B9D-7B7B9379AA1D"

echo "Done."
