# ------------------------------------------------------------------------------
# Environment Variables
# ------------------------------------------------------------------------------
export ATUIN_NOBIND=true
export GOPATH=$HOME/.go
export EDITOR="nvim"
export _ZO_DOCTOR=0
# Ghostty sets TERM=xterm-ghostty which isn't in the default terminfo database
# on remote hosts or older macOS builds — fall back to xterm-256color.
if [[ "$TERM" == "xterm-ghostty" ]] && ! infocmp xterm-ghostty &>/dev/null; then
  export TERM=xterm-256color
fi

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
alias o="open"
alias cat="bat"
alias d="cd ~/code/personal/dotfiles"
alias g="git"
alias k="kubectl"
alias e="nvim"
alias v="nvim"
alias vim="nvim"
alias tf="terraform"
alias c='clear'
alias cc="claude"
alias ccc="claude --allow-dangerously-skip-permissions"
alias cccc="claude --allow-dangerously-skip-permissions --continue"

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
bindkey '^[OA' atuin-up-searchexport 
