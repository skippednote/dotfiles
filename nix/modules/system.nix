# System-wide settings shared by every host.
{ user, ... }:

{
  # Determinate Nix owns the daemon and /etc/nix/nix.conf. Leaving this on
  # makes nix-darwin fight it for both on every activation.
  nix.enable = false;

  # Required by current nix-darwin for any user-scoped option to resolve.
  system.primaryUser = user;

  # Set once at adoption; not a version to bump casually.
  system.stateVersion = 6;

  nixpkgs.hostPlatform = "aarch64-darwin";

  # terraform is BSL and 1password-cli is redistributable-only.
  nixpkgs.config.allowUnfree = true;

  users.users.${user}.home = "/Users/${user}";

  # Puts the Nix profiles on PATH via /etc/zshenv, which runs before the
  # user's .zshrc. Without this nothing adds them, and doing it by hand in
  # .zshrc hoists Nix above mise's per-project tool directories, silently
  # overriding every pinned version. This is only the shell integration;
  # .zshrc stays hand-written and home-manager-linked.
  programs.zsh.enable = true;

}
