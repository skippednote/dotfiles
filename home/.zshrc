# ------------------------------------------------------------------------------
# Environment Variables
# ------------------------------------------------------------------------------
export ATUIN_NOBIND=true
export GOPATH=$HOME/.go
export EDITOR="nvim"
export _ZO_DOCTOR=0
# cmux is built on Ghostty's terminal stack and may set TERM=xterm-ghostty.
# Fall back on hosts that do not have that terminfo entry installed.
if [[ "$TERM" == "xterm-ghostty" ]] && ! infocmp xterm-ghostty &>/dev/null; then
  export TERM=xterm-256color
fi

# ------------------------------------------------------------------------------
# Path
# ------------------------------------------------------------------------------
export path=(
  # Nix first, so tool resolution does not depend on Homebrew winning.
  # home-manager installs user packages under /etc/profiles/per-user.
  /etc/profiles/per-user/$USER/bin
  /run/current-system/sw/bin
  /nix/var/nix/profiles/default/bin
  /opt/homebrew/bin
  $HOME/.local/bin
  $HOME/.go/bin
  $HOME/.cargo/bin
  $path
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
alias l="lsd -lh --git --icon auto"
alias a="lsd -lha --git --icon auto"
alias ls="lsd --icon auto"
alias tree="lsd --tree --icon auto"
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
# ------------------------------------------------------------------------------
# 4Cs
# ------------------------------------------------------------------------------
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
bindkey '^[OA' atuin-up-search

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/skippednote/.lmstudio/bin"
# End of LM Studio CLI section
