# Starship prompt initialization
starship init fish | source
# set -x STARSHIP_CONFIG ~/.config/starship/starship.toml

# Language environment
set -x LANG en_US.UTF-8

# Editor
set -x EDITOR /usr/bin/nvim

# GPG's TTY variable
set -x GPG_TTY (tty)

# Set wine prefix
set -x WINEPREFIX /essd/wine

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
alias dka="docker kill $(docker ps -q)"

# Directory navigation aliases
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'

# GO
# set -x GOPATH /Users/omerhamerman/go

# VIM alias
alias v='/usr/bin/nvim'

# Nmap alias
alias nm='nmap -sC -sV -oN nmap'

# Set PATH
# set PATH /usr/local/bin /usr/bin /bin /usr/sbin /sbin /Users/omer/.vimpkg/bin $GOPATH/bin /Users/omerhamerman/.cargo/bin $PATH

alias cl='clear'

# K8S aliases
# set -x KUBECONFIG ~/.kube/config
# alias k='kubectl'
# alias ka='kubectl apply -f'
# alias kg='kubectl get'
# alias kd='kubectl describe'
# alias kdel='kubectl delete'
# alias kl='kubectl logs'
# alias kgpo='kubectl get pod'
# alias kgd='kubectl get deployments'
# alias kc='kubectx'
# alias kns='kubens'
# alias kl='kubectl logs -f'
# alias ke='kubectl exec -it'
# alias kcns='kubectl config set-context --current --namespace'
# alias podname=''

# HTTP requests with xh!
alias http='xh'

# Fish has built-in VI mode support, configure it if needed
# Fish VI mode can be enabled with:
# fish_vi_key_bindings

# Eza aliases
alias l='eza -l --icons --git -a'
alias la='eza --tree --level=2 --long --icons --git'

# FZF integration (Fish can source the FZF configuration directly)
# set -x FZF_DEFAULT_COMMAND 'fd --type f --hidden --follow'
# test -f ~/.fzf.fish; and source ~/.fzf.fish

# Additional PATH setting
# set -x PATH /opt/homebrew/bin $PATH

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

# Source yazi yy script
source ~/.config/yazi/yy.sh

# Set theme
set -g theme_color_scheme dark 
set -g theme_nerd_fonts yes

# Created by `pipx` on 2024-06-05 20:15:03
set PATH $PATH /home/matei/.local/bin

# Nvim man page
set -gx MANPAGER 'nvim +Man!'
