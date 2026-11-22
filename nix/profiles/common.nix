# Tools every machine gets.
#
# The split was drawn from a real inventory of both machines rather than
# guessed: 13 of these were already installed on both, and the seven shell
# tools were on skippednote only - skippedbook had no prompt, no fuzzy
# finder, no directory jumping and no better cat/ls/diff, which is worth
# fixing everywhere rather than treating as a developer luxury.
{
  pkgs,
  agentPkgs,
  user,
  ...
}:

{
  home-manager.users.${user}.home.packages =
    with pkgs;
    [
      # Shell, prompt and navigation
      starship
      zoxide
      zsh-autosuggestions
      fzf
      lsd
      bat
      fd
      delta

      # Upstream's prebuilt 18.21.0, because nixpkgs cannot build it yet
      # (18.21 needs rustc 1.98 and no revision has it) and its history
      # database will not downgrade. See nix/packages/atuin.nix.
      (callPackage ../packages/atuin.nix { })

      # Files, text and inspection
      ripgrep
      bottom

      # Runtimes both machines use
      go
      nodejs
      pnpm
      rustc

      # Cloud and secrets both machines use
      awscli2
      cloudflared
      sops

      # git
      gh

      # Kept installed purely to serve per-project mise.toml files; the
      # global [tools] list is empty on both machines.
      mise
    ]
    ++ [
      # From the separate nixpkgs-agents input so it can be updated on its
      # own cadence. skippedbook was running 2.1.150 against skippednote's
      # 2.1.258 under `latest`; one pinned revision ends that drift.
      agentPkgs.claude-code # provides `claude`
    ];
}
