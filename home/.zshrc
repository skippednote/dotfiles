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
# Do not put the Nix profiles at the front here. `mise activate` inserts its
# per-project tool directories relative to this array, and hoisting Nix above
# them silently overrides every pinned version: a project asking for terraform
# 1.15.8 or node 18 would get the global Nix build instead.
#
# Nix still wins over Homebrew without any help, because Homebrew is down to
# mas and zsh-autosuggestions and no longer overlaps the Nix package set.
export path=(
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

# ------------------------------------------------------------------------------
# sdkman (JVM toolchains; installed by bootstrap.sh, not by Nix)
# ------------------------------------------------------------------------------
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"
