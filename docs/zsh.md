# Zsh setup

Reference for everything in `common/zsh/.zshrc` and the CLI tools around it.
Edit the config in the repo (it's symlinked to `~/.zshrc`); reload with `exec zsh`.

---

## Keybinding cheat-sheet

The prompt is in **vi mode**. `Esc` (or Caps Lock) drops to normal mode; `i`/`a` back to insert.
`KEYTIMEOUT=1` so `Esc` responds instantly instead of the 0.4s default.

| Key | Mode | Action |
|-----|------|--------|
| `Tab` | insert | Fuzzy completion via **fzf-tab** (files, dirs, git, docker, flags…) with live preview |
| `→` / `End` | insert | Accept the gray **autosuggestion** from history |
| `Ctrl-R` | insert | Fuzzy search command **history** (fzf) |
| `Ctrl-T` | insert | Fuzzy-pick a **file** and insert it into the line (fd-powered, bat preview) |
| `Alt-C` | insert | Fuzzy-pick a **directory** and `cd` into it (fd-powered, eza preview) |
| `**`+`Tab` | insert | fzf **trigger** completion, e.g. `vim **<Tab>`, `cd **<Tab>` |
| `v` | normal | Open the half-written command in **nvim**; `:wq` runs it |
| `Ctrl-W` / `Ctrl-U` | insert | Delete word / line back — restored past the insert-start boundary |
| `Ctrl-A` / `Ctrl-E` | insert | Start / end of line — emacs habits kept in insert mode |
| `cd <name>` | — | **zoxide** smart jump to a frecency-ranked directory |
| `cdi` | — | zoxide **interactive** directory picker |

The prompt character tells you the mode: `❯` insert, `❮` normal (starship `vimcmd_symbol`).

---

## Prompt & shell behaviour

- **Starship** — the prompt. Config in `common/starship/.config/starship.toml`. Single line:
  directory, git branch/status, command duration (>2s), mode-aware `❯`.
- **`EDITOR=nvim`** / `VISUAL=nvim` — everything that shells out to an editor (git commit,
  `crontab -e`, `fc`, the `v` binding above) uses nvim.
- **History** — 50,000 entries, shared live across sessions, deduped, timestamped.
  Prefix a command with a space to keep it out of history. `HIST_VERIFY` shows `!!`
  expansions before running them.
- **`BAT_THEME="Solarized (dark)"`** and `CLICOLOR=1` so `bat` and plain `ls` match the rest.

---

## Completion system

- `compinit` powers `docker`, `git`, `brew`, `gh` etc. completions; functions come from
  `$ZSH_SITE_FUNCS` (set per-OS in `~/.config/zsh/os.zsh`).
- **Case-insensitive + fuzzy matching**: `cd doc<Tab>` matches `Documents`.
- **fzf-tab** replaces the completion menu with an fzf picker. Preview panes:
  - `cd` → directory contents via **eza**.
  - `cat`, `bat`, `less`, `more`, `head`, `tail`, `vim`, `nvim`, `nano` → file contents via
    **bat**; directories fall back to eza; images render as a **chafa** thumbnail.
  - To add another file-reader, append it to the `(cat|bat|…)` alternation in `.zshrc`.

---

## fzf

- Bindings loaded via `source <(fzf --zsh)` — guarded by `[[ -t 0 ]]` so nested/non-tty
  shells don't error.
- Backed by **fd**: respects `.gitignore`, includes hidden files, skips `.git`.
- Default look: `--height 40% --layout=reverse --border`.

---

## Plugins (load order matters)

1. `compinit` — completion engine, first.
2. **fzf-tab** — after compinit, before autosuggestions.
3. **zsh-autosuggestions** — strategy `(match_prev_cmd completion)`: predicts the command
   that usually *follows* the one you just ran, then falls back to completion data.
4. **zoxide** — `cd` replacement. `_ZO_DOCTOR=0` silences its "I should be last" warning,
   because syntax-highlighting genuinely has to be last.
5. **zsh-syntax-highlighting** — must be the final plugin sourced.
6. `~/.zshrc.local` — machine-local overrides, sourced last, never committed.

Plugin paths come from `$ZSH_PLUGIN_DIR`, set in `~/.config/zsh/os.zsh`
(`mac/zsh` → Homebrew share dir; `linux/zsh` → `/usr/share/zsh/plugins`).

---

## Aliases

| Alias | Expands to |
|-------|-----------|
| `ls`, `ll` | `eza -lah --git --group-directories-first --icons=auto` |
| `lt` | `eza --tree --level=2 --icons=auto` |

---

## CLI tools (Brewfile.core)

Run `tldr <cmd>` for quick examples of any of these.

| Tool | Replaces | What it does |
|------|----------|-------------|
| **eza** | `ls` | Listing with icons, git status, tree mode |
| **bat** | `cat` | Syntax-highlighted viewer, Solarized Dark |
| **fd** | `find` | Fast file search; respects `.gitignore` |
| **rg** (ripgrep) | `grep` | Fast recursive content search |
| **fzf** | — | Fuzzy finder behind Tab / `Ctrl-R` / `Ctrl-T` / `Alt-C` |
| **zoxide** | `cd` | Frecency directory jumping |
| **jq** / **yq** | — | JSON / YAML processors |
| **btop** | `top` | Resource monitor |
| **dust** | `du` | Visual disk-usage tree |
| **duf** | `df` | Friendly free-space view |
| **procs** | `ps` | Process viewer with colour and search |
| **lazygit** | — | Terminal git UI |
| **gh** | — | GitHub CLI |
| **tldr** (tlrc) | `man` | Community cheat-sheets |
| **chafa** | — | Terminal image renderer (fzf-tab previews) |

---

## tmux

`common/tmux/.tmux.conf` plus two scripts in `common/bin/.local/bin`:

| Key | Action |
|-----|--------|
| `prefix f` | **tmux-sessionizer** — fuzzy-pick a project (zoxide frecency + `~/development`), create or switch session |
| `prefix s` | **tmux-sessions** — switch between live sessions; `Ctrl-X` kills the highlighted one |
| `prefix h/j/k/l` | Move between panes; `H/J/K/L` resize |
| `prefix \|` / `-` | Split vertical / horizontal in the current path |
| `Alt-H` / `Alt-L` | Previous / next window |
| `prefix r` | Reload config |
| `prefix Ctrl-S` / `Ctrl-R` | Save / restore sessions (tmux-resurrect) |
| `prefix I` | Install plugins declared in `.tmux.conf` (TPM) |

A repo can drop an executable `.tmux-sessionizer` in its root to lay out windows on first open.

Plugins are managed by [TPM](https://github.com/tmux-plugins/tpm) in `~/.tmux/plugins`
(cloned by the installer). tmux-continuum auto-saves every 15 minutes and restores
the last save when the server starts, so a killed server costs at most 15 minutes
of layout. Saves live in `~/.local/share/tmux/resurrect`. Auto-save silently stays
off if continuum sees another tmux process at load time (a stray client, a server
on a second socket) — check with `tmux show -gv status-right | grep -c continuum`.

---

## Maintenance

```sh
brew update && brew upgrade   # update all tools/plugins
exec zsh                      # reload after editing .zshrc
zsh -n ~/.zshrc               # syntax-check without running
```
