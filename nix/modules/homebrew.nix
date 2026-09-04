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

    # Mac App Store apps are deliberately NOT declared here. Managing them
    # through brew bundle failed three separate ways on this machine:
    #
    #   1. During activation mas could not enumerate installed apps, so the
    #      install phase queued all seven - which would have re-downloaded
    #      Xcode over an identical copy.
    #   2. The cleanup phase silently removed nothing for the same reason,
    #      so undeclared apps were never actually uninstalled by zap.
    #   3. Once Keynote, Numbers and Pages were deleted by hand, mas kept
    #      reporting them as installed, so every switch printed
    #      "Uninstalled 3 Mac App Store apps" and did nothing.
    #
    # The pre-migration Makefile set HOMEBREW_BUNDLE_MAS_SKIP for exactly
    # this reason; dropping that was a mistake.
    #
    # So this stays empty on purpose - it is not an unfinished list. The apps
    # in use are installed by hand from the App Store and upgraded with
    # `make mas-update`; for reference when rebuilding a machine, they are
    # Developer (640199958), WireGuard (1451685025) and Xcode (497799835).
    masApps = { };
  };
}
