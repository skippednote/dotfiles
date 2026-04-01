#!/usr/bin/env bash
# macOS defaults — run once after a fresh install, then log out/restart.
set -euo pipefail

echo "Applying macOS defaults..."

# Dock
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock tilesize -int 16
defaults write com.apple.dock orientation -string left
defaults write com.apple.dock show-recents -bool false
defaults write com.apple.dock minimize-to-application -bool true

# Finder
defaults write com.apple.finder ShowPathbar -bool false
defaults write com.apple.finder ShowStatusBar -bool false

# Dark mode
defaults write NSGlobalDomain AppleInterfaceStyle -string Dark

# Restart affected apps
killall Dock
killall Finder

echo "Done. Some changes may require a logout or restart."
