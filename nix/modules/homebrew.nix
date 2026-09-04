# Shared Homebrew policy. The brews, casks and masApps lists live in the
# host files, because the two machines share only orbstack and tailscale.
#
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
  };
}
