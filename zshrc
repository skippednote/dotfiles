export GOPATH=$HOME/.go
export PYENV_ROOT=$HOME/.pyenv
export ATUIN_NOBIND=true
export BAT_THEME=base16

export path=(
  $path
  /opt/homebrew/bin
  /usr/local/nvim/bin
  $HOME/.cargo/bin
  $HOME/.local/bin
  $HOME/Library/Application Support/JetBrains/Toolbox/scripts
  $HOME/.yarn/bin
  $PYENV_ROOT/bin
)


# initializations
eval "$(starship init zsh)"
eval "$(fnm env --use-on-cd)"
eval "$(zoxide init zsh)"
eval "$(atuin init zsh)"
eval "$(pyenv init -)"
source "$HOME/.sdkman/bin/sdkman-init.sh"
source <(helm completion zsh)
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# aliases
alias l="eza -lh --git --icons"
alias a="eza -lha --git --icons"
alias ls="eza --git --icons"
alias cd='z'
alias v='nvim'
alias c='clear'
alias o="open"
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
