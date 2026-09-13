# macOS-specific shell setup — sourced early by ~/.zshrc.
# Homebrew prefix is Apple Silicon by default; falls back to Intel.
HOMEBREW_PREFIX="${HOMEBREW_PREFIX:-$([[ -d /opt/homebrew ]] && echo /opt/homebrew || echo /usr/local)}"

ZSH_SITE_FUNCS="$HOMEBREW_PREFIX/share/zsh/site-functions"
ZSH_PLUGIN_DIR="$HOMEBREW_PREFIX/share"
