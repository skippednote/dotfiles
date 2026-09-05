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

echo "==> 3/4 First darwin-rebuild switch"
# darwin-rebuild does not exist yet on a fresh machine, so run it straight from
# the flake this once. sudo resets PATH to a secure default that excludes
# /nix/..., so resolve nix absolutely first.
NIX_BIN="$(command -v nix)"
sudo "$NIX_BIN" run github:nix-darwin/nix-darwin/master#darwin-rebuild -- \
  switch --flake "$DIR#$HOST"

echo "==> 4/4 sdkman"
# Owns JVM version switching. Not in nixpkgs: only fishPlugins.sdkman-for-fish
# (wrong shell) and sdkmanager (Android, unrelated).
#
# Runs after the switch because it needs nix on PATH: its installer refuses
# the bash 3.2 macOS ships, and a modern one is fetched with `nix run` rather
# than kept in the package set.
#
# rcupdate=false matters: .zshrc is a symlink into this repo, and sdkman would
# otherwise append its init block to the tracked file. .zshrc sources sdkman
# itself instead.
if [ "$HOST" != "skippednote" ]; then
  echo "    skipped: $HOST does not use JVM toolchains"
elif [ ! -d "$HOME/.sdkman" ]; then
  # sdkman's installer refuses to run on the bash 3.2 macOS ships, so it is
  # fed a modern one from nixpkgs on demand. Fetched rather than kept in the
  # package set: nothing else here needs bash 4+, and installing a shell
  # permanently to satisfy one line of one-time setup is the wrong trade.
  if ! curl -s "https://get.sdkman.io?rcupdate=false" | nix run nixpkgs#bash; then
    echo "    sdkman install failed; re-run this script to retry."
  fi
else
  echo "    already installed"
fi

cat <<EOF

Bootstrap complete. Remaining manual steps:

  1. Open 1Password, sign in, and enable the SSH agent
     (Settings > Developer). Commit signing and SSH depend on it.
  3. mise install                # per-project tools, inside each project
  4. Restore from 1Password: ~/.ssh private keys, ~/.aws, ~/.kube,
     ~/.config/gcloud, ~/.gnupg, ~/.codex/auth.json
  5. Log out and back in for all macOS defaults to take effect.
EOF
