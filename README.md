# dotfiles

Solarized Dark, everywhere. Vi keys, everywhere. One repo for macOS and Linux.

<!-- screenshot: aerospace + sketchybar + ghostty running nvim/tmux -->
<!-- ![desktop](docs/screenshot.png) -->

**Stack:** zsh + starship · nvim (LazyVim) · tmux · ghostty ·
AeroSpace + SketchyBar + JankyBorders (mac) · Omarchy (linux, WIP)

## Install

```sh
git clone https://github.com/Loxstomper/dotfiles ~/development/dotfiles
cd ~/development/dotfiles
./install.sh
```

Every package group is prompted — `A`ll, `n`one, or `p`ick one at a time — so
a work machine can skip the personal stuff. Re-running is safe: it only installs
what's missing and re-links configs.

## Layout

Each directory under `common/` and `mac/` is a [stow](https://www.gnu.org/software/stow/)
package that mirrors `~`. `common/zsh/.zshrc` → `~/.zshrc`,
`mac/sketchybar/.config/sketchybar/` → `~/.config/sketchybar/`.

```
install.sh          detects the OS, hands off
lib.sh              shared helpers: prompts, stow with backup, git identity
common/             both OSes
  zsh/ git/ tmux/ starship/ btop/ nvim/
  bin/              tmux-sessionizer, tmux-sessions
  theme/            solarized-dark.sh — the canonical hex values
mac/
  install.sh        Xcode CLT → Homebrew → packages → stow → defaults
  Brewfile.core     shell + CLI tools, every machine
  Brewfile.wm       AeroSpace, SketchyBar, borders
  Brewfile.dev      go, node, docker, postgres, …
  Brewfile.personal ollama, audacity, openscad, …
  defaults.sh       macOS settings (dark mode, dock, key repeat, caps→esc)
  zsh/ ghostty/ aerospace/ sketchybar/ borders/ bin/
linux/              Omarchy — see linux/README.md
docs/zsh.md         keybinding cheat-sheet: shell, fzf, tmux, plugins
```

## What the installer does

1. Xcode CLT and Homebrew if missing.
2. For each Brewfile group, ask; run `brew bundle` on what you picked.
3. Stow `common/*` and `mac/zsh`, `mac/bin` always. Stow `nvim`, `ghostty`,
   `aerospace`, `sketchybar`, `borders` only if that tool is installed — you
   never get a config for something you didn't ask for.
4. Anything already at a target path is moved to `~/.dotfiles-backup/<timestamp>/`.
   Never `stow --adopt`.
5. Clone [TPM](https://github.com/tmux-plugins/tpm) and install the plugins
   `.tmux.conf` declares (resurrect + continuum for session save/restore).
6. Prompt for git name/email → `~/.gitconfig.local`.
7. Optionally apply `mac/defaults.sh`.

## Machine-local files

Never committed. The tracked configs source these if present:

| File | Purpose |
|------|---------|
| `~/.zshrc.local` | work aliases, company tooling, anything with a token in it |
| `~/.gitconfig.local` | `[user]` name/email — the tracked `.gitconfig` has no identity and sets `useConfigOnly` so git refuses to guess |
| `~/.config/ghostty/config.local` | font size / opacity for this screen |
| `~/.config/zsh/os.zsh` | stowed from `mac/zsh` or `linux/zsh` — Homebrew vs pacman paths |
| `~/.tmux/plugins/` | TPM and its plugins, cloned by the installer (or `prefix I`) |
| `~/.local/share/tmux/resurrect/` | tmux session saves — continuum writes one every 15 min |

## Adding a config

1. Make `common/<tool>/` (or `mac/<tool>/`) with the file at its path relative to `~`.
2. Add a `stow_pkg` / `stow_if` line in `mac/install.sh`.
3. `stow --no-folding -R -d common -t ~ <tool>` — or just re-run `./install.sh`.

Colours: shell-based configs (`sketchybar`, `borders`) source
`~/.config/theme/solarized-dark.sh`. Tools with a built-in Solarized theme
(ghostty, bat, nvim) use it by name. Hand-coded hex elsewhere (tmux, starship)
should match the theme file.

## Notes

- `plugins/display.sh` (sketchybar) saves and replays monitor layouts with
  `displayplacer`, and regenerates AeroSpace's top gap. Profiles in
  `mac/sketchybar/.config/sketchybar/profiles/` are tied to specific panels
  (the `id:` is a per-unit hash), so on a new machine — even the same model:
  ```sh
  displayplacer list                       # get this panel's id
  displayplacer "id:<ID> res:3024x1964 hz:60 color_depth:8 scaling:off origin:(0,0) degree:0"
  display.sh save laptop                   # overwrite the profile with this panel's id
  ```
  Ghostty's `font-size = 26` and the sketchybar `dense` preset assume that
  1:1 `scaling:off` mode; at the macOS default HiDPI scaling everything renders
  about twice as large.
- `.zshrc` sets `_ZO_DOCTOR=0`: zoxide and zsh-syntax-highlighting both want to
  be sourced last; highlighting actually needs it.
- Public repo. `pre-commit install` enables a gitleaks hook.
