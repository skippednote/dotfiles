# Dotfiles

Two Macs, managed with [Determinate Nix](https://determinate.systems/),
[nix-darwin](https://github.com/nix-darwin/nix-darwin) and
[home-manager](https://github.com/nix-community/home-manager).

| Host | What it is |
| --- | --- |
| `skippednote` | development laptop |
| `skippedbook` | self-hosting box: an OrbStack Kubernetes cluster, LM Studio, and 24 launchd agents driving `~/selfhost` |

## Layout

```
flake.nix                        entry point; mkHost and both hosts
nix/hosts/<host>.nix             hostname, Homebrew lists, per-host defaults
nix/modules/system.nix           platform, unfree, zsh integration
nix/modules/defaults.nix         macOS preferences shared by both
nix/modules/homebrew.nix         shared Homebrew policy
nix/modules/home.nix             dotfile placement
nix/profiles/common.nix          tools both machines get
nix/profiles/dev.nix             skippednote only
nix/profiles/ops.nix             skippedbook only
nix/agents/skippedbook/          launchd agents, split by risk
nix/packages/atuin.nix           upstream binary; nixpkgs cannot build 18.21
home/                            the real dotfiles, symlinked into $HOME
nix/modules/gc.nix               weekly store garbage collection
nix/agents/skippednote/          the press backup agent
scripts/drift-check.sh           repo-vs-machine divergence
scripts/drift-notify.sh          launchd wrapper; alerts on change only
scripts/packages-lock.sh         regenerates packages.lock
packages.lock                    committed package + Homebrew set, both hosts
tests/bootstrap.sh               stubbed harness for bootstrap.sh
.github/workflows/check.yml      CI
```

## Daily use

```bash
make switch      # apply the configuration
make check       # evaluate and dry-build, changing nothing
make drift       # has this machine diverged from the repo?
make packages-lock  # regenerate packages.lock after changing the package set
make update      # flake inputs, system, brew, package lock, App Store
make test        # bootstrap.sh harness
make fmt         # nix fmt
```

`make switch` needs no host argument: `HOST` comes from
`scutil --get LocalHostName`, which returns `skippednote` and `skippedbook`
on the respective machines. That matters more than convenience — a mistyped
host would rename the machine and swap its entire cask set.

Files under `home/` are the live config. They are symlinked into `$HOME`, not
copied, so editing them takes effect immediately; only changes under `nix/`
need a switch.

Rolling back:

```bash
darwin-rebuild --list-generations
darwin-rebuild --rollback
```

Two things generations do not undo: Homebrew removals
(`onActivation.cleanup = "zap"`, so anything undeclared is uninstalled) and
`system.defaults` writes.

## Fresh machine

```bash
git clone https://github.com/skippednote/dotfiles.git ~/Code/personal/dotfiles
cd ~/Code/personal/dotfiles
./bootstrap.sh
```

Five steps: Xcode CLI tools, Determinate Nix, Homebrew, first switch, then
sdkman — skipped on any host but `skippednote`, since nothing else uses a JVM.
The clone path matters: `home.nix` links dotfiles out of the worktree at
`~/Code/personal/dotfiles`.

**This has never run on genuinely bare hardware.** `make test` covers its
control flow across five simulated machine states, but the real installer,
`darwin-rebuild` and sdkman on a virgin machine are untested.

## How dotfiles are linked

`home.nix` uses `mkOutOfStoreSymlink`, so `~/.zshrc` points at `home/.zshrc`
in this repo rather than a read-only copy in `/nix/store`. That is required,
not stylistic — several of these files are rewritten by the tools that read
them:

| File | Written by |
| --- | --- |
| `.zshrc` | LM Studio CLI appends a PATH block |
| `.gitconfig` | `gh auth` writes credential helpers |
| `.ssh/config-skippedbook` | 1Password appends its `IdentityAgent` block |
| `.config/nvim/lazy-lock.json` | lazy.nvim |

Those writes land in the worktree, where `git status` shows them, instead of
being silently clobbered on the next apply. `make drift` exists to notice.

Only `.config/nvim` is linked as a directory. Everything else is linked file
by file, because the parent directories hold state this repo must not own:
`~/.ssh` has private keys, `~/.claude` has daemon logs and caches, `~/.codex`
has auth and state, `~/.local/bin` has hand-installed binaries.

Two files are per-host, because a shared version breaks one machine:

- **`.gitconfig`** includes `~/.config/git/host.conf`. Signing needs
  1Password's `op-ssh-sign`; on `skippedbook` the agent prompts for approval
  on its own display, which nobody can answer over SSH, so signing is off
  there and commits are attributed but unsigned.
- **`.ssh/config`** — `skippednote` routes identities through the 1Password
  agent and includes Upsun's certificate config; `skippedbook` needs
  OrbStack's `Include` first in the file, and pointing `IdentityAgent` at a
  socket that did not exist once broke every outbound ssh there.

## PATH ordering

`.zshrc` slots the Nix profiles **between** mise and the system directories.
Both extremes are wrong, and both were tried:

- Listing the Nix profiles in the `path` array puts them ahead of mise's
  per-project tool directories, silently overriding every pin — terraform
  1.15.8 becomes 1.16.0, rust 1.94.0 becomes 1.97.1.
- Leaving them out drops Nix behind `/usr/local/bin` and `~/.local/bin`, so a
  system python or a stray installer shim wins — which is how ansible ended
  up unable to import boto3 and `claude` ran months behind.

`~/.cargo/bin` joins the front group because mise's rust "install" is a
symlink to it: the pinned toolchain is whatever rustup has active.

## Tooling

CLI tools come from nixpkgs, tracking `nixpkgs-unstable`. The stable
`26.05-darwin` channel was rejected: it is a major version behind on `helm`
and carries neither `herdr` nor `markitdown`. The agent CLIs come from a
second `nixpkgs-agents` input that deliberately does not follow the first, so
they can be moved with `nix flake update nixpkgs-agents` without dragging
everything else.

Not from Nix, and why:

- **Per-project versions** — `node 18` is not in nixpkgs at all, and
  `terraform 1.15.8`, `xcodegen 2.45.4` and `rust 1.94.0` differ from the
  locked revision. mise handles these; its global `[tools]` list is empty on
  both machines.
- **`java`** — sdkman owns JVM switching. `maven` stays in Nix: its wrapper
  sets `JAVA_HOME` with `--set-default`, so it defers to sdkman's export.
- **`batt`** — the only tool on `skippedbook` nixpkgs does not carry.
- **GUI and App Store apps** — Homebrew handles macOS bundles, updates and
  quarantine properly. App Store apps are installed by hand; `mas` enumerates
  through Spotlight and only agrees with reality while that index is healthy.

`ansible` is ansible-core from Nix, outside a python env. `python3` carries
`boto3`/`botocore` because ansible does not run modules in its own
environment — it discovers an interpreter and runs them there.

## skippedbook's launchd agents

25 agents, declared in `nix/agents/skippedbook/`, split by what a mistake
costs:

- **`scheduled.nix`** — 18 timer-driven and run-at-load jobs. A misfiring
  timer surfaces in its own log on the next tick.
- **`services.nix`** — five keepalive services plus the atuin daemon. A
  mistake here is an outage.

nix-darwin owns the schedule and the command. The scripts live in
`~/selfhost`, its own git repo, and source `~/selfhost/.env` — **no secret
from that machine belongs here.**

The hermes gateway pins `nodejs_26` by store path: it needs node 26 while the
user profile carries the 24 LTS, and adding a second nodejs to the profile
would collide.

Worth knowing when editing these: nix-darwin *copies* user agent plists
rather than symlinking them, and only touches one when `diff` reports a
change — so a byte-equivalent change produces no visible difference in
`~/Library/LaunchAgents`. The evidence of ownership is
`/run/current-system/user/Library/LaunchAgents`.

## Not managed

Installed by hand; reinstall after a fresh setup:

- `~/.local/bin/session-manager-plugin`, `android`, `agent`, `cursor-agent`,
  `cursor`, `gs`, `gws-personal`, `gws-work`
- `Fynn.app` — direct download
- App-level settings for Raycast, CleanShot and 1Password
- `~/.claude/settings.json` and `settings.local.json` — Claude Code rewrites
  both, and they carry machine-specific state
- `~/.codex/config.toml`, `~/.config/cmux/cmux.json` — regenerated by their
  own tools
- `~/.sdkman`, `~/selfhost` — manage themselves

Credentials stay out of this repo. Restore from 1Password:

- `~/.ssh` private keys (only `~/.ssh/config` is managed)
- `~/.gnupg`, `~/.aws`, `~/.kube`, `~/.config/gcloud`, `~/.codex/auth.json`

## macOS defaults

`nix/modules/defaults.nix` is intentionally personal: keyboard preferences,
11 text replacements and the Caps Lock remap, shared by both hosts. Dock,
Finder, Rectangle and Raycast settings live in `nix/hosts/skippednote.nix`,
since neither Rectangle nor Raycast is installed on the other machine.

Two notes for anyone porting this: `enableKeyMapping` must be on or
`remapCapsLockToControl` is silently a no-op, and the `wvous-*-corner`
options are typed `ints.positive`, which rejects the `0` that disables a hot
corner — those go through `CustomUserPreferences`.
