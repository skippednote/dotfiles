# Dotfiles

Personal macOS setup, managed with [Determinate Nix](https://determinate.systems/),
[nix-darwin](https://github.com/nix-darwin/nix-darwin), and
[home-manager](https://github.com/nix-community/home-manager).

One command takes a bare Mac to configured, and every change is an atomic
generation you can roll back.

## Layout

- `flake.nix` — entry point; declares the `personal` host
- `nix/modules/system.nix` — platform, unfree, fonts, state version
- `nix/modules/defaults.nix` — macOS preferences and the Caps Lock remap
- `nix/modules/homebrew.nix` — casks, Mac App Store apps, 2 formulae
- `nix/modules/packages.nix` — global CLI tools
- `nix/packages/atuin.nix` — upstream atuin binary; nixpkgs cannot build 18.21
- `nix/modules/home.nix` — dotfile placement
- `home/` — the real dotfiles, symlinked into `$HOME`
- `bootstrap.sh` — fresh-machine setup

## Fresh install

```bash
git clone https://github.com/skippednote/dotfiles.git ~/Code/personal/dotfiles
cd ~/Code/personal/dotfiles
./bootstrap.sh
```

That installs the Xcode CLI tools, Determinate Nix, and sdkman, then runs the
first `darwin-rebuild switch`. It prints the remaining manual steps: signing
into 1Password, per-project mise tools, and restoring credentials.

The clone path matters. `nix/modules/home.nix` links dotfiles out of the
worktree at `~/Code/personal/dotfiles`, so cloning elsewhere means editing
the `repo` path in that file.

## Daily use

```bash
make switch      # apply the configuration
make check       # evaluate and dry-build, changing nothing
make update      # flake inputs, system, brew, mise, App Store
```

Files under `home/` are the live config — they are symlinked into `$HOME`, not
copied, so editing them takes effect immediately with no rebuild. Only changes
to a `nix/` module need `make switch`.

Rolling back:

```bash
darwin-rebuild --list-generations
darwin-rebuild --rollback
```

Two things generations do not undo: Homebrew removals (`homebrew.onActivation.cleanup`
is `zap`, so anything undeclared is uninstalled) and `system.defaults` writes.

## How dotfiles are linked

`home.nix` uses `mkOutOfStoreSymlink`, so `~/.zshrc` points at
`home/.zshrc` in this repo rather than a read-only copy in `/nix/store`.
That is required, not stylistic: six of these files are rewritten by the
tools that read them.

| File | Written by |
| --- | --- |
| `.zshrc` | LM Studio CLI appends a PATH block |
| `.gitconfig` | `gh auth` writes credential helpers |
| `.ssh/config` | Upsun CLI writes a certificate block |
| `.config/gh/config.yml` | `gh` rewrites it |
| `.config/nvim/lazy-lock.json` | lazy.nvim |
| `.claude/settings.json` | Claude Code |

Those writes now land in the worktree, where `git status` shows them.

Only `.config/nvim` is linked as a directory. Everything else is linked file
by file, because the parent directories hold state this repo must not own:
`~/.ssh` has private keys, `~/.claude` has daemon logs and caches, `~/.codex`
has auth and state, `~/.local/bin` has hand-installed binaries.

## Tooling

CLI tools come from nixpkgs, tracking `nixpkgs-unstable`. The stable
`26.05-darwin` channel was rejected: it is a major version behind on `helm` and
does not carry `herdr` or `markitdown` at all.

`mise` is still installed, but its global `[tools]` list is empty. Its
real job now is the per-project `mise.toml` files, which pin versions
unstable cannot provide.

Not from Nix, and why:

- `node 18` — not in nixpkgs at all, and `terraform 1.15.8`, `xcodegen 2.45.4`
  and `rust 1.94.0` differ from the locked revision. On mise, per project.
- `java` — sdkman owns JVM switching. `maven` stays in Nix; its wrapper uses
  `--set-default JAVA_HOME`, so it defers to sdkman.
- GUI apps and Mac App Store apps — Homebrew handles macOS bundles,
  updates, and quarantine properly.

`ansible` is ansible-core 2.21.3 from Nix, deliberately outside a python env,
with `boto3`/`botocore` injected via `overridePythonAttrs`. Note that ansible
modules run under a separately-discovered interpreter, so `amazon.aws` still
fails to import them — unresolved.

## Not managed

Installed by hand; reinstall after a fresh setup:

- `~/.local/bin/session-manager-plugin` — AWS installer
- `~/.local/bin/android` — Android platform tool
- `~/.local/bin/agent`, `~/.local/bin/cursor-agent`, `~/.local/bin/cursor` —
  Cursor agent installer
- `~/.local/bin/gs`, `gws-personal`, `gws-work` — hand-written shims
- `Fynn.app` — direct download
- App-level settings for Raycast, CleanShot, and 1Password
- `~/.claude/settings.local.json` — rewritten constantly by Claude Code
- `~/.codex/config.toml` — Codex rewrites it on every trust/plugin change
- `~/.config/cmux/cmux.json` — cmux regenerates this on launch
- `~/.sdkman` — sdkman manages its own directory

Credentials stay out of this repo. Restore from 1Password:

- `~/.ssh` private keys (only `~/.ssh/config` is managed)
- `~/.gnupg`, `~/.aws`, `~/.kube`, `~/.config/gcloud`, `~/.codex/auth.json`

## macOS defaults

`nix/modules/defaults.nix` is intentionally personal: Dock and Finder
behaviour, keyboard preferences, 11 text replacements, Rectangle and Raycast
settings, the Caps Lock remap, and the computer name. Read it before applying
on a machine that should not use these exact preferences.
