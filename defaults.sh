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
defaults write com.apple.finder FXPreferredViewStyle -string clmv
defaults write com.apple.finder NewWindowTarget -string PfHm
defaults write com.apple.finder FXPreferredGroupBy -string Kind

# Finder — auto-empty trash after 30 days, hide hard drives on desktop
defaults write com.apple.finder FXRemoveOldTrashItems -bool true
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool false

# Window Management — disable macOS native tiling (Rectangle handles this)
defaults write com.apple.WindowManager GloballyEnabled -bool false
defaults write com.apple.WindowManager EnableTiledWindowMargins -bool false
defaults write com.apple.WindowManager EnableTilingByEdgeDrag -bool false
defaults write com.apple.WindowManager EnableTilingOptionAccelerator -bool false
defaults write com.apple.WindowManager EnableTopTilingByEdgeDrag -bool false
defaults write com.apple.WindowManager HideDesktop -bool true

# Mission Control — don't auto-rearrange spaces
defaults write com.apple.dock mru-spaces -bool false

# Hot Corners — bottom-left: Quick Note, rest disabled
defaults write com.apple.dock wvous-tl-corner -int 0
defaults write com.apple.dock wvous-tr-corner -int 0
defaults write com.apple.dock wvous-bl-corner -int 14
defaults write com.apple.dock wvous-br-corner -int 0

# Menu bar clock
defaults write com.apple.menuextra.clock ShowDayOfWeek -bool true
defaults write com.apple.menuextra.clock ShowAMPM -bool true
defaults write com.apple.menuextra.clock ShowDate -int 0
defaults write com.apple.menuextra.clock ShowSeconds -bool false

# Dark mode
defaults write NSGlobalDomain AppleInterfaceStyle -string Dark

# Keyboard — disable text corrections
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool true

# Text replacements
defaults write NSGlobalDomain NSUserDictionaryReplacementItems -array \
  '{ on = 1; replace = "@lin"; with = "https://www.linkedin.com/in/skippednote"; }' \
  '{ on = 1; replace = "fe"; with = "frontend"; }' \
  '{ on = 1; replace = "@p"; with = "mail@skippednote.dev"; }' \
  '{ on = 1; replace = "upi"; with = "skippednote@okhdfcbank"; }' \
  '{ on = 1; replace = "@c"; with = "bassam@axelerant.com"; }' \
  '{ on = 1; replace = "@z"; with = "https://axelerant.zoom.us/my/skippednote"; }' \
  '{ on = 1; replace = "ahd"; with = "Alhamdullialh"; }' \
  '{ on = 1; replace = "@@"; with = "skippednote@gmail.com"; }' \
  '{ on = 1; replace = "asa"; with = "Assalamu Alaikum"; }' \
  '{ on = 1; replace = "ws"; with = "Wa-Alaikum-Salaam"; }' \
  '{ on = 1; replace = "isa"; with = "In Sha Allah"; }'

# Keyboard — remap Caps Lock to Control
hidutil property --set '{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":0x700000039,"HIDKeyboardModifierMappingDst":0x7000000E0}]}' >/dev/null

# Trackpad — tap to click
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# Rectangle — window manager
defaults write com.knollsoft.Rectangle launchOnLogin -bool true
defaults write com.knollsoft.Rectangle hideMenubarIcon -bool true
defaults write com.knollsoft.Rectangle alternateDefaultShortcuts -bool true
defaults write com.knollsoft.Rectangle allowAnyShortcut -bool true
defaults write com.knollsoft.Rectangle subsequentExecutionMode -int 1

# Raycast — Cmd+Space (replaces Spotlight)
defaults write com.raycast.macos raycastGlobalHotkey -string "Command-49"

# Computer name
sudo scutil --set ComputerName "skippednote"
sudo scutil --set HostName "skippednote"
sudo scutil --set LocalHostName "skippednote"

# Restart affected apps
killall Dock
killall Finder

echo "Done. Some changes may require a logout or restart."
