starship init fish | source

set -x LANG en_US.UTF-8
set -x EDITOR /usr/bin/nvim
set -x GPG_TTY (tty)
fish_add_path --path $HOME/.bun/bin $HOME/.local/bin
set -g fish_greeting
set -g fish_key_bindings fish_vi_key_bindings

alias c='bat'
alias vv="~/.config/dotfiles/scripts/vv.sh"

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

alias dco='docker compose'
alias dps='docker ps'
alias dpa='docker ps -a'
alias dl='docker ps -l -q'
alias dx='docker exec -it'
alias dka="docker kill (docker ps -q)"

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'

alias v='/usr/bin/nvim'

alias nm='nmap -sC -sV -oN nmap'

alias cl='clear'

alias http='xh'

alias l='eza -l --icons --git -a'
alias la='eza --tree --level=2 --long --icons --git'

function cx
    cd $argv; and la
end
function fcd
    cd (find . -type d -not -path '*/.*' | fzf); and la
end
function f
    find . -type f -not -path '*/.*' | fzf | wl-copy
end
function fv
    nvim (find . -type f -not -path '*/.*' | fzf)
end

zoxide init fish | source
alias cd="z"

set -g theme_color_scheme dark
set -g theme_nerd_fonts yes

set -gx MANPAGER 'nvim +Man!'
