# Linux (Omarchy)

Not written yet. The plan, so future-me doesn't start from scratch:

Omarchy is opinionated — it ships and manages its own Hyprland, Waybar, Ghostty,
LazyVim and starship configs, and has a theme system under
`~/.config/omarchy/themes/<name>/` with one file per app. So the Linux side is
**not** "stow everything over bare Arch" like the old i3 setup was. It's:

1. Install Omarchy.
2. Add a Solarized Dark theme to Omarchy's theme dir, built from
   `common/theme/.config/theme/solarized-dark.sh` values.
3. Stow only the `common/` packages Omarchy doesn't own (`zsh`, `git`, `tmux`,
   `bin`, `theme`, `btop`) plus `linux/zsh` for the Arch plugin paths.
4. Apply LazyVim tweaks as overrides in Omarchy's nvim config rather than
   replacing it.

`linux/install.sh` should mirror `mac/install.sh`: pacman/yay groups instead of
Brewfiles, same `ask_group` / `stow_pkg` helpers from `lib.sh`.
