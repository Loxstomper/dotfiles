export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/go/bin:$PATH"

# OS-specific paths (homebrew prefix, plugin locations). Stowed from mac/zsh or
# linux/zsh — see the dotfiles repo. Defines $ZSH_PLUGIN_DIR and $ZSH_SITE_FUNCS.
[[ -f "$HOME/.config/zsh/os.zsh" ]] && source "$HOME/.config/zsh/os.zsh"

# history — large, shared across sessions, deduped
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY          # share history live across sessions
setopt HIST_IGNORE_ALL_DUPS   # drop older duplicates of a command
setopt HIST_FIND_NO_DUPS      # don't surface dupes when searching
setopt HIST_IGNORE_SPACE      # leading space keeps a command out of history
setopt HIST_REDUCE_BLANKS     # trim superfluous whitespace
setopt HIST_VERIFY            # show expansion (e.g. !!) before running
setopt EXTENDED_HISTORY       # record timestamps

# Starship prompt
eval "$(starship init zsh)"

# ls — eza (modern replacement)
export CLICOLOR=1   # fallback for `command ls`
alias ls='eza -lah --git --group-directories-first --icons=auto'
alias ll='eza -lah --git --group-directories-first --icons=auto'
alias lt='eza --tree --level=2 --icons=auto'

# bat — Solarized Dark theme
export BAT_THEME="Solarized (dark)"

# completion system — MUST init before fzf-tab; also enables docker/git/brew completions
fpath=(${ZSH_SITE_FUNCS:-/opt/homebrew/share/zsh/site-functions} $fpath)
autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'  # case-insensitive + fuzzy

# vi mode at the prompt. EDITOR/VISUAL were unset, which is why zsh defaulted
# to emacs — and why anything shelling out to an editor (git commit, crontab -e,
# fc) fell back to whatever each tool hardcodes.
export EDITOR=nvim
export VISUAL=nvim
bindkey -v
KEYTIMEOUT=1                        # default 0.4s Esc lag reads as the shell hanging

# 'v' in normal mode opens the half-written command in $EDITOR
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey -M vicmd v edit-command-line

# zsh's vi insert mode won't delete back past where insert began. Restore the
# expected behaviour in insert mode only — normal mode keeps real vi semantics.
bindkey -M viins '^?' backward-delete-char
bindkey -M viins '^H' backward-delete-char
bindkey -M viins '^W' backward-kill-word
bindkey -M viins '^U' backward-kill-line
bindkey -M viins '^A' beginning-of-line
bindkey -M viins '^E' end-of-line


# fzf — use fd (respects .gitignore, includes hidden, skips .git) + previews
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border"
[[ -t 0 ]] && source <(fzf --zsh)  # only with a real tty — avoids "can't change option: zle" in nested shells
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:500 {}'"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
export FZF_ALT_C_OPTS="--preview 'eza -1 --color=always --icons --group-directories-first {}'"

# fzf-tab — seamless fzf picker on plain Tab (load after compinit, before autosuggestions)
zstyle ':completion:*' menu no                       # let fzf-tab take over the menu
zstyle ':fzf-tab:complete:cd:*' fzf-preview \
  'eza -1 --color=always --icons --group-directories-first $realpath'  # dir preview for cd
zstyle ':fzf-tab:complete:(cat|bat|less|more|head|tail|vim|nvim|nano):*' fzf-preview \
  'if [[ -d $realpath ]]; then
     eza -1 --color=always --icons --group-directories-first $realpath
   elif [[ ${realpath:l} == *.(png|jpg|jpeg|gif|webp|bmp|tiff|tif|ico) ]]; then
     chafa -f symbols -s ${FZF_PREVIEW_COLUMNS:-80}x${FZF_PREVIEW_LINES:-25} $realpath
   else
     bat --color=always --style=numbers --line-range=:500 $realpath
   fi'  # dir → eza, image → chafa thumbnail (symbols mode, tmux-safe), else bat
source "${ZSH_PLUGIN_DIR:-/opt/homebrew/share}/fzf-tab/fzf-tab.zsh"

# zsh-autosuggestions — fish-like history suggestions (accept with → or End)
ZSH_AUTOSUGGEST_STRATEGY=(match_prev_cmd completion)   # predict next step from workflow history, else completion
source "${ZSH_PLUGIN_DIR:-/opt/homebrew/share}/zsh-autosuggestions/zsh-autosuggestions.zsh"

# zoxide — replaces `cd` (cd = smart jump, cdi = interactive picker)
# _ZO_DOCTOR=0: zoxide wants to be sourced last, but so does syntax-highlighting
# (which genuinely needs it). Silence the doctor warning rather than reorder.
export _ZO_DOCTOR=0
eval "$(zoxide init zsh --cmd cd)"

# zsh-syntax-highlighting — real-time command colorizing — MUST be the VERY LAST plugin sourced
source "${ZSH_PLUGIN_DIR:-/opt/homebrew/share}/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# machine-local overrides (work aliases, company tooling, secrets) — never committed
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
