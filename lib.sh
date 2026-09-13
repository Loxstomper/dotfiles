#!/usr/bin/env bash
# Shared helpers for the OS-specific installers. Sourced, not executed.
# Expects $DOTFILES to be the repo root.

# ---- output -----------------------------------------------------------------
if [ -t 1 ]; then
  _c_blue=$'\033[34m' _c_green=$'\033[32m' _c_yellow=$'\033[33m' _c_red=$'\033[31m' _c_dim=$'\033[2m' _c_reset=$'\033[0m'
else
  _c_blue='' _c_green='' _c_yellow='' _c_red='' _c_dim='' _c_reset=''
fi
info()  { printf '%s→%s %s\n' "$_c_blue" "$_c_reset" "$*"; }
ok()    { printf '%s✓%s %s\n' "$_c_green" "$_c_reset" "$*"; }
warn()  { printf '%s!%s %s\n' "$_c_yellow" "$_c_reset" "$*" >&2; }
die()   { printf '%s✗%s %s\n' "$_c_red" "$_c_reset" "$*" >&2; exit 1; }
header(){ printf '\n%s== %s ==%s\n' "$_c_blue" "$*" "$_c_reset"; }

# ---- prompts ----------------------------------------------------------------
# ask "question" [default y|n]  → returns 0 for yes, 1 for no
ask() {
  local q="$1" def="${2:-y}" hint reply
  [[ "$def" == y ]] && hint='[Y/n]' || hint='[y/N]'
  while true; do
    read -r -p "$q $hint " reply
    reply="${reply:-$def}"
    case "$reply" in
      [Yy]*) return 0 ;;
      [Nn]*) return 1 ;;
    esac
  done
}

# ask_group "Label" path/to/Brewfile
# Prompts All / none / pick. Prints the path of a temp Brewfile containing the
# selected lines (empty string if nothing selected). tap lines are always kept
# so picked packages from third-party taps still resolve.
ask_group() {
  local label="$1" file="$2" count reply out
  count=$(grep -cE '^(brew|cask) ' "$file")
  while true; do
    read -r -p "$label ($count packages)  [A]ll / [n]one / [p]ick: " reply
    case "${reply:-a}" in
      [Aa]*) printf '%s' "$file"; return ;;
      [Nn]*) printf ''; return ;;
      [Pp]*) break ;;
    esac
  done

  out=$(mktemp -t dotfiles-brewfile)
  grep -E '^tap ' "$file" > "$out" || true
  local line name desc
  # fd 3 for the file so prompts inside the loop still read stdin
  while IFS= read -r -u 3 line; do
    [[ "$line" =~ ^(brew|cask)\ \"([^\"]+)\" ]] || continue
    name="${BASH_REMATCH[2]}"
    desc="${line#*#}"; [[ "$desc" == "$line" ]] && desc='' || desc="  ${_c_dim}#${desc}${_c_reset}"
    if ask "  ${BASH_REMATCH[1]} $name$desc" y; then
      printf '%s\n' "$line" >> "$out"
    fi
  done 3< "$file"

  if grep -qE '^(brew|cask) ' "$out"; then
    printf '%s' "$out"
  else
    rm -f "$out"; printf ''
  fi
}

# ---- stow -------------------------------------------------------------------
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

# _backup_conflicts pkgdir pkgname
# For every file in the package, if the target in ~ exists and is not already a
# symlink into $DOTFILES, move it to $BACKUP_DIR. Never uses stow --adopt: that
# would pull the machine's version into the repo.
_backup_conflicts() {
  local dir="$1" pkg="$2" src rel target real
  while IFS= read -r -d '' src; do
    rel="${src#"$dir/$pkg/"}"
    target="$HOME/$rel"
    if [ -L "$target" ]; then
      # already ours (stow makes relative links, so resolve first) — restow handles it
      real=$(readlink -f "$target" 2>/dev/null || true)
      [[ "$real" == "$DOTFILES"/* ]] && continue
      mkdir -p "$BACKUP_DIR/$(dirname "$rel")"
      mv "$target" "$BACKUP_DIR/$rel"
      warn "backed up foreign symlink ~/$rel"
    elif [ -e "$target" ]; then
      mkdir -p "$BACKUP_DIR/$(dirname "$rel")"
      mv "$target" "$BACKUP_DIR/$rel"
      warn "backed up ~/$rel"
    fi
  done < <(find "$dir/$pkg" -type f -print0)
}

# stow_pkg dir pkgname   e.g. stow_pkg "$DOTFILES/common" zsh
stow_pkg() {
  local dir="$1" pkg="$2"
  [ -d "$dir/$pkg" ] || { warn "no package $dir/$pkg"; return 1; }
  _backup_conflicts "$dir" "$pkg"
  # --no-folding: always link files, never whole directories, so behaviour is
  # identical on a fresh machine and an existing one.
  stow --no-folding --restow -d "$dir" -t "$HOME" "$pkg" && ok "stowed $pkg"
}

# stow_if cmd dir pkg — stow only when the tool is actually installed
stow_if() {
  local probe="$1" dir="$2" pkg="$3"
  if command -v "$probe" >/dev/null 2>&1 || [ -e "$probe" ]; then
    stow_pkg "$dir" "$pkg"
  else
    info "skipping $pkg ($probe not installed)"
  fi
}

# ---- git identity -----------------------------------------------------------
# Writes ~/.gitconfig.local if missing. The tracked .gitconfig includes it and
# sets user.useConfigOnly, so git refuses to commit until this exists.
setup_git_identity() {
  local f="$HOME/.gitconfig.local" name email
  if [ -f "$f" ]; then ok "git identity already set ($f)"; return; fi
  ask "Set up git identity for this machine?" y || return 0
  read -r -p "  name:  " name
  read -r -p "  email: " email
  printf '[user]\n\tname = %s\n\temail = %s\n' "$name" "$email" > "$f"
  ok "wrote $f"
}

# ---- tmux plugins -----------------------------------------------------------
# Clones TPM if missing and installs whatever .tmux.conf declares. tpm reads the
# @plugin lines from the conf file, but starts a server on the default socket to
# ask it where plugins live — a live server is reused (never killed); a fresh one
# exits again as soon as the command returns.
setup_tmux_plugins() {
  local tpm="$HOME/.tmux/plugins/tpm"
  command -v tmux >/dev/null 2>&1 || { info "skipping tmux plugins (tmux not installed)"; return 0; }
  if [ ! -d "$tpm" ]; then
    info "cloning tpm"
    git clone -q --depth 1 https://github.com/tmux-plugins/tpm "$tpm"
  fi
  "$tpm/bin/install_plugins" >/dev/null 2>&1 || warn "tpm install_plugins failed — run 'prefix I' inside tmux"
  ok "tmux plugins"
}
