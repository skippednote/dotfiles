# Global CLI tools.
#
# These used to come from mise (57 entries) and `uv tool` (15). mise stays
# installed, but only to serve the per-project mise.toml files in ~/Code;
# its global [tools] list is trimmed to what nixpkgs cannot provide.
{ pkgs, user, ... }:

{
  home-manager.users.${user}.home.packages = with pkgs; [
    # Languages and runtimes. java is deliberately absent: sdkman owns JVM
    # version switching. nixpkgs' maven wrapper sets JAVA_HOME with
    # --set-default, so it defers to sdkman's export rather than overriding.
    go
    nodejs
    python3
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
    atuin
    fzf
    lsd

    # Files and text
    bat
    fd
    ripgrep
    delta
    dust
    bottom
    tokei
    glow
    pandoc

    # Git, editor and code
    gh
    lazygit
    neovim
    golangci-lint
    gopls # was an undeclared Homebrew formula; declared here before zap
    cargo-binstall
    cargo-deny # was an undeclared mise install
    basedpyright
    ruff
    protobuf # provides protoc
    xcodegen

    # Cloud and infrastructure. gcloud and cloud-sql-proxy stay on mise.
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

    # Were undeclared conda installs under mise, adopted here. postgresql_17
    # rather than the default 18.6: mise had 17.11, and a major bump cannot
    # read an existing v17 data directory without pg_upgrade.
    ffmpeg
    vips
    postgresql_17

    # Docs, media and automation. Top-level `ansible` is ansible-core
    # (2.21.3) rather than the 14.3.1 collection bundle, which is the
    # deliberate trade for keeping it out of a python env.
    markitdown
    yt-dlp
    zola
    poetry

    # boto3/botocore are injected into ansible's own interpreter rather than
    # through python3.withPackages, so ansible stays a normal top-level
    # package. Without them amazon.aws modules fail at import.
    (ansible.overridePythonAttrs (old: {
      dependencies = (old.dependencies or [ ]) ++ [
        python3Packages.boto3
        python3Packages.botocore
      ];
    }))

    # Agents and tooling. claude, codex and pi-coding-agent are absent on
    # purpose: they self-update, which a read-only store breaks.
    rtk
    herdr
    mise
  ];
}
