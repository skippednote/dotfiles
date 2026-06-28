# Dotfiles

Personal macOS dotfiles and fresh-machine setup.

This repo uses [chezmoi](https://www.chezmoi.io/) for dotfile deployment. The managed home-directory state lives in `home/`; the root-level scripts handle provisioning, macOS defaults, and convenience commands.

## Layout

- `home/` - chezmoi source directory for files applied into `$HOME`
- `Brewfile` - Homebrew formulae, casks, and Mac App Store apps
- `bootstrap.sh` - fresh Mac bootstrap flow
- `defaults.sh` - opinionated macOS defaults
- `Makefile` - local maintenance commands
- `lazy.lua` - LazyVim override, linked separately after the LazyVim starter repo is installed
- `uv-tools.sh` - installs global `uv tool` CLIs (not tracked by mise)

Key managed files include:

- `~/.zshrc`
- `~/.gitconfig`
- `~/.gitignore`
- `~/.config/mise/config.toml`
- `~/.config/starship.toml`
- `~/.config/gh/config.yml`
- `~/.config/cmux/cmux.json`
- `~/.config/ai/working-preferences.md`
- `~/.claude/settings.json`
- `~/.claude/CLAUDE.md`
- `~/.claude/AGENTS.md`
- `~/.claude/RTK.md`
- `~/.codex/AGENTS.md`
- `~/.codex/RTK.md`
- `~/.codex/hooks.json`
- `~/.ssh/config`
- `~/Library/LaunchAgents/com.skippednote.capslock-to-control.plist`
- `~/.local/bin/imgcat`
- `~/.local/bin/rtk-claude-hook`

## Fresh Install

```bash
git clone https://github.com/skippednote/dotfiles.git ~/code/personal/dotfiles
cd ~/code/personal/dotfiles
make bootstrap
```

The bootstrap flow:

- installs Xcode Command Line Tools if missing
- installs `chezmoi` and `mise` into `~/.local/bin`
- installs Homebrew if missing
- installs packages from `Brewfile`
- applies dotfiles from `home/` with `chezmoi`
- installs CLI tools from `~/.config/mise/config.toml`
- installs global `uv tool` CLIs from `uv-tools.sh`
- installs or updates LazyVim and links `lazy.lua`
- applies macOS defaults from `defaults.sh`
- switches Docker to the OrbStack context when available

## Common Commands

```bash
make bootstrap-tools
```

Installs the pre-dotfiles bootstrap tools, `chezmoi` and `mise`, into `~/.local/bin`.

```bash
make install
```

Applies the `home/` source state into `$HOME` with `chezmoi`.

```bash
make check
```

Checks whether the expected managed files exist.

```bash
make clean
```

Removes files managed by this repo from `$HOME`.

```bash
make clean-tools
```

Removes only the standalone bootstrap binaries installed by `make bootstrap-tools`: `~/.local/bin/chezmoi` and `~/.local/bin/mise`.

```bash
make brew-clean
```

Shows Homebrew formulae and casks that are not declared in `Brewfile`.

```bash
make brew-clean-force
```

Removes Homebrew formulae and casks that are not declared in `Brewfile`. This can uninstall GUI apps, so review `make brew-clean` first.

```bash
make clean-all
```

Runs `clean`, `clean-tools`, and `brew-clean-force`. This removes managed dotfiles, removes bootstrap binaries, and uninstalls Homebrew formulae/casks not declared in `Brewfile`.

```bash
make lazyvim
```

Installs or updates the LazyVim starter config, then links the repo-managed `lazy.lua` override.

```bash
make defaults
```

Applies macOS defaults.

```bash
make dump
```

Regenerates the `Brewfile` from the current Homebrew state.

```bash
make uv-tools
```

Installs the global `uv tool` CLIs (ansible, poetry, ruff, yt-dlp, …) that live outside mise. Regenerate the list in `uv-tools.sh` from `uv tool list`.

## Chezmoi Notes

The repo intentionally uses `home/` as the chezmoi source directory instead of making the repository root the source. This keeps project files like `README.md`, `Makefile`, `Brewfile`, and bootstrap scripts out of the managed home state.

To inspect what chezmoi would change:

```bash
chezmoi --source=home --destination="$HOME" diff
```

To apply directly:

```bash
chezmoi --source=home --destination="$HOME" apply
```

## Tooling

`chezmoi` and `mise` are intentionally not installed through Homebrew. They are bootstrap tools, so `bootstrap.sh` installs them directly into `~/.local/bin` before Homebrew or dotfile application runs.

Shell setup is centered on `zsh`, `mise`, `starship`, `zoxide`, `atuin`, `eza`, `bat`, and `zsh-autosuggestions`.

Git is configured with:

- SSH commit signing through the 1Password SSH agent
- `delta` as the pager
- rebase-on-pull
- pruning on fetch
- a set of short aliases for common Git operations

CLI runtimes and tools are managed by `mise`, including Node, Python, Go, Terraform, Kubernetes tools, Neovim, Claude, Codex, and related development utilities.

Both assistants share one working-preferences file at `~/.config/ai/working-preferences.md`, imported by `~/.claude/CLAUDE.md` and `~/.codex/AGENTS.md`; assistant-specific overrides stay in those two files.

Claude Code uses `~/.claude/CLAUDE.md` to import `~/.claude/RTK.md` and the shared `~/.config/ai/working-preferences.md`, plus `~/.local/bin/rtk-claude-hook` as a small compatibility wrapper around `rtk hook claude`. The wrapper preserves RTK rewrites and adds Claude's required `permissionDecision: "allow"` when RTK returns `updatedInput`. `~/.claude/AGENTS.md` imports the same shared files for tools that read `AGENTS.md`.

Codex uses `~/.codex/AGENTS.md` to import `~/.codex/RTK.md` and the shared working-preferences file, plus its own Codex-specific rules; `~/.codex/hooks.json` configures its RTK hook. Codex state, auth, logs, and caches are intentionally not managed.

## Personal Defaults

`defaults.sh` is intentionally personal. It sets Dock/Finder behavior, keyboard preferences, text replacements, Rectangle/Raycast preferences, Caps Lock remapping, and the macOS computer name.

Review it before running on a machine that should not use these exact preferences.
