# ------------------------------------------------------------------------------
# Environment Variables
# ------------------------------------------------------------------------------
export ATUIN_NOBIND=true
export GOPATH=$HOME/.go
export PHP_INI_SCAN_DIR="$HOME/.config/herd-lite/bin:$PHP_INI_SCAN_DIR"
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
  $HOME/.config/herd-lite/bin
)

# ------------------------------------------------------------------------------
# Tool Initializations
# ------------------------------------------------------------------------------
eval "$(starship init zsh)"
eval "$(zoxide init zsh)"
eval "$(atuin init zsh)"
eval "$(fnm env --use-on-cd --shell zsh)"

# Load zsh-autosuggestions if available
if [ -f /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
  source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi
# Load SDKMAN if available
if [ -f .sdkman/bin/sdkman-init.sh ]; then  
  source .sdkman/bin/sdkman-init.sh
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
alias ca="cursor-agent"
alias tor="npx webtorrent-cli"

# ------------------------------------------------------------------------------
# Functions
# ------------------------------------------------------------------------------
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
