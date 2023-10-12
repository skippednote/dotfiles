# set path
set -g fish_greeting
set -g fish_user_paths /opt/homebrew/bin $HOME/.cargo/bin $fish_user_paths
set -Ux GOPATH $HOME/.go
# set -gx ATUIN_NOBIND "true"

# initializations
starship init fish | source
direnv hook fish | source
fnm env | source
zoxide init fish | source
atuin init fish | source

# aliases
alias l="exa -lh --git --icons"
alias a="exa -lha --git --icons"
alias cd='z'
alias v='vim'
alias c='clear'
alias o="open"
alias ls="exa --git --icons"
alias tree="ls --tree --icons"
alias cat="bat"
alias d="cd ~/code/personal/dotfiles"
alias genkeys='ssh-keygen -t ed25519 -C "skippednote@gmail.com" '
alias copykeys='cat ~/.ssh/id_ed25519.pub | pbcopy'
alias g="git"
alias k="kubectl"
alias tor="npx webtorrent-cli "
alias activatepyenv="source ./.venv/bin/activate.fish"

# functions
function mcd
    mkdir $argv[1]
    cd $argv[1]
end

function cdr
    cd (git rev-parse --show-toplevel)
end

function genpyenv -d "Generate python virutal environment and upgrade pip"
    python3 -m venv .venv
    source .venv/bin/activate.fish
    pip install -U pip
end

# Keybindings
bind \cr _atuin_search
bind -M insert \cr _atuin_search
