#!/usr/bin/env bash
# Bootstrap a fresh Mac. Run this once; use `make switch` for every change
# afterwards.
#
# Usage: ./bootstrap.sh [personal|work]
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
HOST="${1:-personal}"

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
if ! command -v nix &>/dev/null; then
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix \
    | sh -s -- install --no-confirm
  # shellcheck disable=SC1091
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
else
  echo "    already installed"
fi

echo "==> 3/4 sdkman"
# Owns JVM version switching. Not in nixpkgs: only fishPlugins.sdkman-for-fish
# (wrong shell) and sdkmanager (Android, unrelated).
#
# rcupdate=false matters: .zshrc is a symlink into this repo, and sdkman would
# otherwise append its init block to the tracked file. .zshrc sources sdkman
# itself instead.
if [ ! -d "$HOME/.sdkman" ]; then
  curl -s "https://get.sdkman.io?rcupdate=false" | bash
else
  echo "    already installed"
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
  2. bash "$DIR/uv-tools.sh"     # the 7 PyPI-only CLIs
  3. mise install                # the 7 tools nixpkgs cannot serve
  4. Restore from 1Password: ~/.ssh private keys, ~/.aws, ~/.kube,
     ~/.config/gcloud, ~/.gnupg, ~/.codex/auth.json
  5. Log out and back in for all macOS defaults to take effect.
EOF
