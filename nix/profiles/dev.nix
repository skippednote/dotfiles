# Development tools: skippednote only.
#
# Anything shared with skippedbook lives in common.nix instead.
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
      cargo
      maven
      bun
      uv

      # Files and text
      dust
      tokei
      glow

      # Git, editor and code
      lazygit
      neovim
      golangci-lint
      cargo-binstall
      ruff
      protobuf # provides protoc
      xcodegen

      # Cloud and infrastructure
      terraform # unfree: BSL
      aws-vault
      aws-sam-cli
      kubernetes-helm # the `helm` binary; nixpkgs' `helm` is a different tool
      k9s
      k6
      wrangler
      upsun
      ddev

      # Secrets
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

      # Agents and tooling
      rtk
      herdr
    ]
    ++ [
      agentPkgs.codex
      agentPkgs.pi-coding-agent # provides `pi`
    ];
}
