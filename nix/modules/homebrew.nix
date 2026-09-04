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

    # mas enumerates App Store apps through Spotlight, and this machine's
    # Spotlight index was read-only on both / and /System/Volumes/Data, so
    # nothing could ever be added to it. That is what made mas unreliable
    # here: during activation it saw a frozen index, reported everything as
    # uninstalled, and brew bundle queued every declared app - which would
    # have re-downloaded Xcode over an identical copy. It also kept listing
    # apps that had already been deleted.
    #
    # Fixed with `sudo mdutil -i on -a && sudo mdutil -E -a`. mas now agrees
    # with what is on disk, so these are declared again.
    #
    # masApps installs but never upgrades; `make mas-update` does that.
    #
    # Xcode (497799835) is deliberately absent - it was uninstalled, and
    # declaring it would pull ~10 GB back down on the next switch. Add it
    # here if a full Xcode toolchain is needed again.
    masApps = {
      "Developer" = 640199958;
      "WireGuard" = 1451685025;
    };
  };
}
