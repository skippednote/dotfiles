export ATUIN_NOBIND=true
export GOPATH=$HOME/.go
export POETRY_VIRTUALENVS_IN_PROJECT=true
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES

export path=(
  $path
  /opt/homebrew/bin
  $HOME/.local/bin
  $HOME/.cargo/bin
)

eval "$(starship init zsh)"
eval "$(zoxide init zsh)"
eval "$(atuin init zsh)"
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# alias
alias l="eza -lh --git --icons"
alias a="eza -lha --git --icons"
alias ls="eza --git --icons"
alias cd='z'
alias c='clear'
alias o="open"
alias tree="ls --tree --icons"
alias cat="bat"
alias d="cd ~/code/personal/dotfiles"
alias g="git"
alias k="kubectl"
alias tf=terraform

# functions
mcd() {
    mkdir $1
    cd $1
}
cdr() {
    cd $(git rev-parse --show-toplevel)
}

# Keybindings
bindkey '^r' atuin-search
bindkey '^[[A' atuin-up-search
bindkey '^[OA' atuin-up-search

