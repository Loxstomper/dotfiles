# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
alias ls="ls -l --color=auto"
alias updates="sudo dnf update && dnf upgrade -y"
alias cls="clear"
alias nettest="ping 8.8.8.8"

# python venv
alias venv="virtualenv ./venv --no-site-packages && activate"
# alias deactivate="/venv/bin"
alias activate="source ./venv/bin/activate"
alias c='clear'
alias m='make'

function mkdire 
{
    mkdir $1 && cd $1 
}

function cdl
{
    cd $1 && ls
}
bind 'set completion-ignore-case on'

# prompt
# red=$(tput setaf 160)
# white=$(tput setaf 255)
# bold=$(tput bold)
# reset=$(tput sgr0)
# PS1="${white}\t ${red}${bold}\u ${white}\w\n👉${reset} ";
# export PS1;

export PATH=$HOME/bin:$PATH
