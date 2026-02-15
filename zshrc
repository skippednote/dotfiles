# ------------------------------------------------------------------------------
# Environment Variables
# ------------------------------------------------------------------------------
export ATUIN_NOBIND=true
export GOPATH=$HOME/.go
export EDITOR="cursor --wait"
export _ZO_DOCTOR=0

# ------------------------------------------------------------------------------
# Path
# ------------------------------------------------------------------------------
export path=(
  $path
  /opt/homebrew/bin
  $HOME/.local/bin
  $HOME/.go/bin
  $HOME/.cargo/bin
)

# ------------------------------------------------------------------------------
# Tool Initializations
# ------------------------------------------------------------------------------
eval "$(mise activate zsh)"
eval "$(starship init zsh)"
eval "$(zoxide init zsh)"
eval "$(atuin init zsh)"
if [ -f /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
  source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

# ------------------------------------------------------------------------------
# Aliases
# ------------------------------------------------------------------------------
alias l="eza -lh --git --icons"
alias a="eza -lha --git --icons"
alias ls="eza --git --icons"
alias tree="ls --tree --icons"
alias cd='z'
alias c='clear'
alias o="open"
alias cat="bat"
alias d="cd ~/code/personal/dotfiles"
alias g="git"
alias k="kubectl"
alias e="cursor"
alias ca="agent"
alias v="nvim"

# ------------------------------------------------------------------------------
# Functions
# ------------------------------------------------------------------------------
tor() {
  if [[ $# -eq 0 ]]; then
    npx webtorrent-cli "$(pbpaste)"
  else
    npx webtorrent-cli "$@"
  fi
}

mcd() {
    mkdir -p "$1" && cd "$1"
}

cdr() {
    cd $(git rev-parse --show-toplevel 2>/dev/null) || echo "Not in a git repository"
}


# ------------------------------------------------------------------------------
# Keybindings
# ------------------------------------------------------------------------------
bindkey '^r' atuin-search
bindkey '^[[A' atuin-up-search
bindkey '^[OA' atuin-up-search
