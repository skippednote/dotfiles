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

# Dock — pinned apps (clear defaults, keep only Mail + Chrome)
defaults write com.apple.dock persistent-apps -array \
  "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/System/Applications/Mail.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>" \
  "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Google Chrome.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>"

# Finder
defaults write com.apple.finder ShowPathbar -bool false
defaults write com.apple.finder ShowStatusBar -bool false

# Dark mode
defaults write NSGlobalDomain AppleInterfaceStyle -string Dark

# Rectangle — window manager
defaults write com.knollsoft.Rectangle launchOnLogin -bool true
defaults write com.knollsoft.Rectangle hideMenubarIcon -bool true
defaults write com.knollsoft.Rectangle alternateDefaultShortcuts -bool true
defaults write com.knollsoft.Rectangle allowAnyShortcut -bool true
defaults write com.knollsoft.Rectangle subsequentExecutionMode -int 1

# Restart affected apps
killall Dock
killall Finder

echo "Done. Some changes may require a logout or restart."
