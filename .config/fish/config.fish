# Starship prompt initialization
starship init fish | source

# Language environment
set -x LANG en_US.UTF-8

# Editor
set -x EDITOR /usr/bin/nvim

# GPG's TTY variable
set -x GPG_TTY (tty)

# Aliases
alias c='bat'
alias vv="~/.config/dotfiles/scripts/vv.sh"

# Git aliases
alias gc='git commit -m'
alias gca='git commit -a -m'
alias gp='git push origin HEAD'
alias gpu='git pull origin'
alias gst='git status'
alias glog="git log --graph --topo-order --pretty='%w(100,0,6)%C(yellow)%h%C(bold)%C(black)%d %C(cyan)%ar %C(green)%an%n%C(bold)%C(white)%s %N' --abbrev-commit"
alias gdiff='git diff'
alias gco='git checkout'
alias gb='git branch'
alias gba='git branch -a'
alias gadd='git add'
alias ga='git add -p'
alias gcoall='git checkout -- .'
alias gr='git remote'
alias gre='git reset'

alias lg='lazygit'

# Docker aliases
alias dco='docker compose'
alias dps='docker ps'
alias dpa='docker ps -a'
alias dl='docker ps -l -q'
alias dx='docker exec -it'
alias dka="docker kill (docker ps -q)"

# Directory navigation aliases
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'

# VIM alias
alias v='/usr/bin/nvim'

# Nmap alias
alias nm='nmap -sC -sV -oN nmap'

alias cl='clear'

# HTTP requests with xh!
alias http='xh'

# Eza aliases
alias l='eza -l --icons --git -a'
alias la='eza --tree --level=2 --long --icons --git'

# Navigation functions
function cx
    cd $argv; and la
end
function fcd
    cd (find . -type d -not -path '*/.*' | fzf); and la
end
function f
    echo (find . -type f -not -path '*/.*' | fzf) | pbcopy
end
function fv
    nvim (find . -type f -not -path '*/.*' | fzf)
end

# Zoxide initialization
zoxide init fish | source
alias cd="z"

# Set theme
set -g theme_color_scheme dark 
set -g theme_nerd_fonts yes

set PATH $PATH $HOME/.local/bin

# Nvim man page
set -gx MANPAGER 'nvim +Man!'
fish_add_path $HOME/.local/bin
