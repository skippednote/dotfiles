#!/usr/bin/env bash
# Bootstrap a fresh Mac. Run this once; use `make switch` for every change
# afterwards.
#
# Usage: ./bootstrap.sh [host]   (host defaults to this machine's name)
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
# Same detection the Makefile uses, so this works unchanged on either
# machine. Override with `./bootstrap.sh <host>` if ever needed.
HOST="${1:-$(scutil --get LocalHostName)}"

# This script runs under bash and never reads .zshrc, so an already-installed
# Nix would otherwise be invisible to the checks below.
NIX_PROFILE_SH=/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
BREW_BIN=/opt/homebrew/bin/brew
if [ -e "$NIX_PROFILE_SH" ]; then
  # The profile script is not written against `set -u`.
  set +u
  # shellcheck disable=SC1090
  . "$NIX_PROFILE_SH"
  set -u
fi

echo "==> 1/4 Xcode Command Line Tools"
# nix-darwin cannot provide these, and several source builds need them.
if ! xcode-select -p &>/dev/null; then
  xcode-select --install
  echo "    Press Enter once the install has finished."
  read -r
else
  echo "    already installed"
fi

echo "==> 2/4 Determinate Nix"
if command -v nix &>/dev/null; then
  echo "    already installed"
else
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix \
    | sh -s -- install --no-confirm
  if [ ! -e "$NIX_PROFILE_SH" ]; then
    echo "    Nix installed but $NIX_PROFILE_SH is missing."
    echo "    Open a new terminal and re-run this script."
    exit 1
  fi
  set +u
  # shellcheck disable=SC1090
  . "$NIX_PROFILE_SH"
  set -u
fi

echo "==> 3/4 Homebrew"
# nix-darwin declares the bundle but never installs brew itself: if
# /opt/homebrew/bin/brew is absent its activation prints one red line and
# carries on, so a fresh Mac would report "Bootstrap complete" with none of
# its 21 casks, 1 formula or 2 App Store apps installed.
if [ -x "$BREW_BIN" ]; then
  echo "    already installed"
else
  NONINTERACTIVE=1 /bin/bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

echo "==> 4/4 First darwin-rebuild switch"
# darwin-rebuild does not exist yet on a fresh machine, so run it straight from
# the flake this once. sudo resets PATH to a secure default that excludes
# /nix/..., so resolve nix absolutely first.
NIX_BIN="$(command -v nix)"
sudo "$NIX_BIN" run github:nix-darwin/nix-darwin/master#darwin-rebuild -- \
  switch --flake "$DIR#$HOST"

cat <<EOF

Bootstrap complete. Remaining manual steps:

  1. Open 1Password, sign in, and enable the SSH agent
     (Settings > Developer). Commit signing and SSH depend on it.
  2. mise install                # per-project tools, inside each project
  3. Restore from 1Password: ~/.ssh private keys, ~/.aws, ~/.kube,
     ~/.config/gcloud, ~/.gnupg, ~/.codex/auth.json
  4. Log out and back in for all macOS defaults to take effect.
EOF
