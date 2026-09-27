# ------------------------------------------------------------------------------
# Environment Variables
# ------------------------------------------------------------------------------
export ATUIN_NOBIND=true
export GOPATH=$HOME/.go
export EDITOR="nvim"
export _ZO_DOCTOR=0
# Ghostty sets TERM=xterm-ghostty.
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

# Slot the Nix profiles ahead of the system directories but behind whatever
# mise has just put in front for this project.
#
# Order matters in both directions. Listing the Nix profiles in the `path`
# array above puts them ahead of mise's per-project tool directories, which
# silently overrides every pinned version (terraform 1.15.8 becomes 1.16.0,
# node 18 becomes 24). Leaving them out entirely drops them behind
# /usr/local/bin and ~/.local/bin, so a system python or a stray installer
# shim wins instead - which is how ansible ended up unable to import boto3.
#
# ~/.cargo/bin is deliberately NOT in the front group any more. It was, for
# rustup: mise's rust "install" is a symlink into it, so a project's pinned
# toolchain was whatever rustup had active, and hoisting it kept Nix's rustc
# from shadowing that. rustup is gone and Nix owns the toolchain, so the
# directory stays on PATH only for what `cargo install` puts there - behind
# the Nix profiles, where a stray binary can no longer win.
_nix_profiles=(/etc/profiles/per-user/$USER/bin /run/current-system/sw/bin)
_front=(${(M)path:#*/mise/installs/*})
path=(${_front} ${_nix_profiles} ${path:|_front})
typeset -U path
unset _nix_profiles _front

# Maven's Nix wrapper sets JAVA_HOME with --set-default, which only applies
# when it is unset - so exporting it here is what makes maven use the JDK on
# PATH rather than the one in its own closure. Derived from `java` rather
# than written out, because the answer is a /nix/store path that changes on
# every update.
_java=$(command -v java 2>/dev/null) && export JAVA_HOME="${${_java:A}:h:h}"
unset _java

eval "$(starship init zsh)"
eval "$(zoxide init zsh)"
eval "$(atuin init zsh)"
# From the Nix per-user profile rather than Homebrew. The profile path is
# stable across updates, unlike a /nix/store path. Sourced via the profile
# because this used to point at /opt/homebrew/share, which does not exist on
# skippedbook - the guard meant that machine silently had no autosuggestions
# at all.
_zsh_autosuggestions=/etc/profiles/per-user/$USER/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
[ -f "$_zsh_autosuggestions" ] && source "$_zsh_autosuggestions"
unset _zsh_autosuggestions

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
alias d="cd ~/Code/personal/dotfiles"
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
export PATH="$PATH:$HOME/.lmstudio/bin"
# End of LM Studio CLI section
