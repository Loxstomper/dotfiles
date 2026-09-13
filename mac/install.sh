#!/usr/bin/env bash
# macOS installer. Safe to re-run: brew bundle and stow are both idempotent,
# and every group is prompted, so re-running to add something you skipped
# just installs the delta.
set -euo pipefail

DOTFILES="${DOTFILES:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
export DOTFILES
# shellcheck source=../lib.sh
source "$DOTFILES/lib.sh"
MAC="$DOTFILES/mac"
COMMON="$DOTFILES/common"

# ---- prerequisites ----------------------------------------------------------
header "Prerequisites"

if ! xcode-select -p >/dev/null 2>&1; then
  info "installing Xcode Command Line Tools (a dialog will open)"
  xcode-select --install
  until xcode-select -p >/dev/null 2>&1; do sleep 5; done
fi
ok "Xcode CLT"

if ! command -v brew >/dev/null 2>&1; then
  for p in /opt/homebrew/bin/brew /usr/local/bin/brew; do
    [ -x "$p" ] && eval "$("$p" shellenv)" && break
  done
fi
if ! command -v brew >/dev/null 2>&1; then
  ask "Homebrew not found. Install it?" y || die "Homebrew is required"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"
fi
ok "Homebrew ($(brew --prefix))"

command -v stow >/dev/null 2>&1 || { info "installing stow"; brew install stow; }
ok "stow"

# ---- packages ---------------------------------------------------------------
header "Packages"
echo "For each group: A = install all, n = skip, p = pick individually."
echo

for group in core wm dev personal; do
  case "$group" in
    core)     label="Core CLI + shell" ;;
    wm)       label="Window manager stack (AeroSpace, SketchyBar, borders)" ;;
    dev)      label="Dev toolchain" ;;
    personal) label="Personal apps" ;;
  esac
  sel=$(ask_group "$label" "$MAC/Brewfile.$group")
  if [ -n "$sel" ]; then
    info "brew bundle ($group)"
    brew bundle --file="$sel" --no-upgrade
    [ "$sel" != "$MAC/Brewfile.$group" ] && rm -f "$sel"   # pick mode makes a temp file
  fi
done

# ---- configs ----------------------------------------------------------------
header "Configs"
echo "Linking configs for whatever is installed. Existing files go to $BACKUP_DIR."
echo

# always
for pkg in theme zsh git tmux starship btop bin; do stow_pkg "$COMMON" "$pkg"; done
stow_pkg "$MAC" zsh
stow_pkg "$MAC" bin

# only if the tool is present
stow_if nvim         "$COMMON" nvim
stow_if /Applications/Ghostty.app   "$MAC" ghostty
stow_if /Applications/AeroSpace.app "$MAC" aerospace
stow_if sketchybar   "$MAC" sketchybar
stow_if borders      "$MAC" borders

setup_tmux_plugins

# background services for the WM stack
for svc in sketchybar borders; do
  # launchctl print, not `brew services list` — the latter omits tap formulae
  if command -v "$svc" >/dev/null 2>&1 && ! launchctl print "gui/$(id -u)/homebrew.mxcl.$svc" >/dev/null 2>&1; then
    ask "Start $svc as a login service?" y && brew services start "$svc"
  fi
done

# ---- identity ---------------------------------------------------------------
header "Git identity"
setup_git_identity

# ---- macOS defaults ---------------------------------------------------------
header "macOS defaults"
if ask "Apply macOS defaults (dark mode, dock, key repeat, caps→esc, …)?" y; then
  bash "$MAC/defaults.sh"
fi

# ---- done -------------------------------------------------------------------
header "Done"
cat <<EOF
Manual steps that can't be scripted:
  • Log out and back in for key repeat, caps lock and menu bar changes.
  • System Settings → Privacy & Security → Accessibility: enable AeroSpace.
  • Open Ghostty once; set it as default terminal if prompted.
  • Machine-local overrides (never committed):
      ~/.zshrc.local                 shell aliases, company tooling, secrets
      ~/.gitconfig.local             git identity (written above)
      ~/.config/ghostty/config.local font size for this screen, etc.
  • Built-in display to native 1:1 (font-size 26 and the sketchybar sizes assume it):
      displayplacer list → displayplacer "id:<ID> res:3024x1964 hz:60 color_depth:8 scaling:off origin:(0,0) degree:0"
      then 'display.sh save laptop'. See README → Notes.
Then: exec zsh
EOF
