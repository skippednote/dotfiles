# Development tools: skippednote only.
#
# Anything shared with skippedbook lives in common.nix instead.
{
  pkgs,
  agentPkgs,
  openspecPkg,
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

      # Languages and runtimes.
      #
      # The Rust toolchain is the whole toolchain, not just cargo. rustup
      # used to own this: it was curl-installed, sat ahead of Nix on PATH,
      # and decided which rustc every project got. Nothing in the flake could
      # see it, and ~/damrs pinned 1.94.0 through it while Nix carried a
      # different rustc entirely. One source now - rustc from common.nix,
      # these alongside it, all 1.98.1 from the same revision.
      #
      # rustfmt and clippy are not optional extras here: `cargo fmt` and
      # `cargo clippy` are separate binaries, and without them both damrs
      # gates fail with "no such subcommand" rather than with a lint.
      cargo
      clippy
      rustfmt
      rust-analyzer

      # JVM. This was sdkman's job - a curl-installed version manager, its
      # own init block in .zshrc, and its own step in bootstrap.sh, all to
      # hold exactly one JDK. temurin-bin-25 is 25.0.4, the same build
      # sdkman had installed as 25.0.4-tem, so adopting it changed the source
      # and nothing else.
      #
      # nixpkgs' maven wrapper sets JAVA_HOME with --set-default, which only
      # applies when it is unset; .zshrc exports it from whichever java is on
      # PATH, so maven follows this JDK rather than its own closure's.
      temurin-bin-25
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
      grpcurl # was installed by hand via brew and undeclared
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

      # acli is not in nixpkgs - upstream ships only a phar. Pinned to the same
      # version the PADI backend's deploy buildspec uses, so a local database
      # pull and a CI deploy run the same binary. See nix/packages/acli.nix.
      (callPackage ../packages/acli.nix { })

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
      openspecPkg # provides `openspec`
      agentPkgs.codex
      agentPkgs.pi-coding-agent # provides `pi`
    ];
}
