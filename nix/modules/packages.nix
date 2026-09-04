# Global CLI tools.
#
# These used to come from mise (57 entries) and `uv tool` (15). mise stays
# installed, but only to serve the per-project mise.toml files in ~/Code;
# its global [tools] list is trimmed to what nixpkgs cannot provide.
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
      # python3 carries boto3/botocore because ansible does not run modules in
      # its own environment - it discovers an interpreter and runs them there,
      # which is the python3 on PATH. Putting the libraries in ansible's own
      # closure looked correct and changed nothing; amazon.aws still failed to
      # import them. This is not a general-purpose python install; it exists so
      # the discovered interpreter has what the AWS modules need.
      (python3.withPackages (ps: [
        ps.boto3
        ps.botocore
      ]))

      # Languages and runtimes. java is deliberately absent: sdkman owns JVM
      # version switching. nixpkgs' maven wrapper sets JAVA_HOME with
      # --set-default, so it defers to sdkman's export rather than overriding.
      go
      nodejs
      rustc
      cargo
      maven
      bun
      pnpm
      uv

      # Shell, prompt and navigation. bash is here because macOS ships 3.2 and
      # sdkman's installer requires 4+.
      bash
      starship
      zoxide
      fzf
      lsd
      # Upstream's prebuilt 18.21.0, because nixpkgs cannot build it yet and
      # its history database will not downgrade. See nix/packages/atuin.nix.
      (callPackage ../packages/atuin.nix { })

      # Files and text
      bat
      fd
      ripgrep
      delta
      dust
      bottom
      tokei
      glow

      # Git, editor and code
      gh
      lazygit
      neovim
      golangci-lint
      gopls # was an undeclared Homebrew formula; declared here before zap
      cargo-binstall
      basedpyright
      ruff
      protobuf # provides protoc
      xcodegen

      # Cloud and infrastructure.
      terraform # unfree: BSL
      awscli2
      aws-vault
      aws-sam-cli
      kubernetes-helm # the `helm` binary; nixpkgs' `helm` is a different tool
      k9s
      k6
      cloudflared
      wrangler
      upsun
      ddev

      # Secrets
      sops
      _1password-cli # unfree

      # Network and data. sshpass leaves Homebrew here, which is what retires
      # the hudochenkov/sshpass tap and the brew-trust target.
      xh
      doggo
      harlequin
      dbmate
      sshpass

      # Docs, media and automation. Top-level `ansible` is ansible-core
      # (2.21.3) rather than the 14.3.1 collection bundle, which is the
      # deliberate trade for keeping it out of a python env.
      markitdown
      yt-dlp
      zola
      poetry

      ansible

      # Agents and tooling. mise stays installed, but only to serve the
      # per-project mise.toml files; its global [tools] list is now empty.
      rtk
      herdr
      mise
    ]
    ++ [
      # From the separate nixpkgs-agents input so these can be updated on
      # their own cadence. Their in-place self-updaters cannot write to the
      # read-only store, so they report being unable to update and defer to
      # the package manager - which is now this file.
      agentPkgs.claude-code # provides `claude`
      agentPkgs.codex
      agentPkgs.pi-coding-agent # provides `pi`
    ];
}
