#!/usr/bin/env bash
# Bootstrap a fresh Mac from scratch.
# Usage: curl the repo or clone it, then run this script.
set -euo pipefail

export PATH="$HOME/.local/bin:/opt/homebrew/bin:$PATH"

echo "==> Installing Xcode Command Line Tools..."
if ! xcode-select -p &>/dev/null; then
  xcode-select --install
  echo "    Waiting for Xcode CLI tools to finish installing..."
  echo "    Press Enter once the installation is complete."
  read -r
fi

echo "==> Installing bootstrap tools..."
make -C "$(dirname "$0")" bootstrap-tools

echo "==> Installing Homebrew..."
if ! command -v brew &>/dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

echo "==> Installing Homebrew packages (Brewfile)..."
brew bundle --file="$(dirname "$0")/Brewfile"

echo "==> Applying dotfiles with chezmoi..."
make -C "$(dirname "$0")" install

echo "==> Installing CLI tools via mise..."
mise install

echo "==> Setting up LazyVim..."
make -C "$(dirname "$0")" lazyvim

echo "==> Applying macOS defaults..."
bash "$(dirname "$0")/defaults.sh"

echo "==> Setting Docker context to OrbStack..."
if command -v docker &>/dev/null; then
  docker context use orbstack 2>/dev/null || echo "    OrbStack context not available yet — set it after opening OrbStack."
fi

echo ""
echo "Bootstrap complete! Next steps:"
echo "  1. Open 1Password and sign in"
echo "  2. Enable SSH agent in 1Password > Settings > Developer"
echo "  3. Open cmux"
echo "  4. Run 'nvim' to let LazyVim install plugins"
echo "  5. Log out and back in for all macOS defaults to take effect"
