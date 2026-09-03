# Homebrew keeps the GUI applications and Mac App Store apps: nixpkgs' darwin
# app coverage is not worth the trade for these, and casks handle macOS
# bundle installation, updates, and quarantine correctly.
#
# This declares the bundle only. Homebrew itself stays hand-installed, so
# taking over a populated /opt/homebrew is not part of this migration.
{ ... }:

{
  homebrew = {
    enable = true;

    # Cleanup stays off until the lists below are proven complete against a
    # real machine. "zap" is the equivalent of the old `make brew-clean-force`,
    # but it fires on every activation rather than on demand, and it removes
    # application support and preference files alongside the app itself.
    onActivation.cleanup = "none";

    # Keep activation fast and deterministic. Upgrading is a deliberate act
    # and belongs in `make update`, not in every switch.
    onActivation.autoUpdate = false;
    onActivation.upgrade = false;

    brews = [
      "mas" # required by masApps below
      "zsh-autosuggestions" # .zshrc sources this from /opt/homebrew/share
    ];

    casks = [
      "1password"
      "blender"
      "chatgpt"
      "claude"
      "cleanshot"
      "cmux"
      "google-chrome"
      "granola"
      "grok-bot"
      "insta360-link-controller"
      "logi-options+"
      "microsoft-teams"
      "notion-calendar"
      "orbstack"
      "raycast"
      "rectangle"
      "slack"
      "tailscale-app"
      "whatsapp"
      "wispr-flow"
      "zed"
      "zoom"
    ];

    # masApps installs but does not upgrade; `mas upgrade` stays in the
    # Makefile for that.
    masApps = {
      "Developer" = 640199958;
      "iMovie" = 408981434;
      "Keynote" = 409183694;
      "Numbers" = 409203825;
      "Pages" = 409201541;
      "WireGuard" = 1451685025;
      "Xcode" = 497799835;
    };
  };
}
