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

    # Removes anything not declared here, on every activation, including
    # application support and preference files. Enabled only after auditing
    # exactly what it would delete: the font cask (nixpkgs provides it now),
    # the sshpass formula and its tap (likewise), the stale oven-sh/bun tap,
    # and nvm, which has no ~/.nvm and is unused. gopls was also undeclared
    # and moved into nix/modules/packages.nix rather than being lost.
    onActivation.cleanup = "zap";

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
    #
    # Note that cleanup = "zap" DOES uninstall undeclared App Store apps.
    # Dropping iWork from this list removed Keynote (409183694), Numbers
    # (409203825) and Pages (409201541) from the machine. iMovie (408981434)
    # was also dropped but survived, because it is not indexed in Spotlight
    # and mas therefore cannot see it - do not rely on that.
    masApps = {
      "Developer" = 640199958;
      "WireGuard" = 1451685025;
      "Xcode" = 497799835;
    };
  };
}
