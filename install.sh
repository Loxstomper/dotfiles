#!/usr/bin/env bash
# Entry point. Detects the OS and hands off to the matching installer.
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export DOTFILES

case "$(uname -s)" in
  Darwin) exec "$DOTFILES/mac/install.sh" "$@" ;;
  Linux)
    if [ -x "$DOTFILES/linux/install.sh" ]; then
      exec "$DOTFILES/linux/install.sh" "$@"
    fi
    echo "linux/install.sh not written yet — see linux/README.md" >&2
    exit 1
    ;;
  *) echo "unsupported OS: $(uname -s)" >&2; exit 1 ;;
esac
