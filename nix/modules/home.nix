# Dotfile placement.
#
# Every link is an out-of-store symlink into the worktree rather than a copy
# into /nix/store, because six of these files are written by the tools that
# read them: .zshrc (LM Studio appends a PATH block), .gitconfig (gh auth
# writes credential helpers), .ssh/config (the Upsun CLI writes a cert
# block), .config/gh/config.yml (gh rewrites it), nvim's lazy-lock.json
# (lazy.nvim), and .claude/settings.json (Claude Code). Store copies are
# read-only and would break all six.
#
# Only .config/nvim is linked as a directory. Everything else is linked file
# by file, because the directories involved hold state this repo must not
# own: ~/.ssh has private keys, ~/.claude has daemon logs and caches,
# ~/.codex has auth and state, ~/.local/bin has hand-installed binaries.
{ config, user, ... }:

let
  repo = "${config.home.homeDirectory}/Code/personal/dotfiles/home";
  link = path: config.lib.file.mkOutOfStoreSymlink "${repo}/${path}";
in

{
  home.username = user;
  home.homeDirectory = "/Users/${user}";

  # Set once when home-manager adopted this account. Not a version to bump.
  home.stateVersion = "26.11";

  home.file = {
    # Shell and git
    ".zshrc".source = link ".zshrc";
    ".gitconfig".source = link ".gitconfig";

    # Kept un-dotted in the repo: as home/.gitignore its contents would
    # become an active gitignore governing the whole home/ tree.
    ".gitignore".source = link "gitignore";

    # XDG config
    ".config/starship.toml".source = link ".config/starship.toml";
    ".config/mise/config.toml".source = link ".config/mise/config.toml";
    ".config/gh/config.yml".source = link ".config/gh/config.yml";
    ".config/ai/working-preferences.md".source = link ".config/ai/working-preferences.md";

    # The whole LazyVim tree, including the lockfile nvim rewrites.
    ".config/nvim".source = link ".config/nvim";

    # Agents. settings.local.json, config.toml, auth and state stay unmanaged.
    ".claude/settings.json".source = link ".claude/settings.json";
    ".claude/CLAUDE.md".source = link ".claude/CLAUDE.md";
    ".claude/AGENTS.md".source = link ".claude/AGENTS.md";
    ".claude/RTK.md".source = link ".claude/RTK.md";
    ".codex/AGENTS.md".source = link ".codex/AGENTS.md";
    ".codex/RTK.md".source = link ".codex/RTK.md";
    ".codex/hooks.json".source = link ".codex/hooks.json";

    # Only the config; private keys are never managed here.
    ".ssh/config".source = link ".ssh/config";

    # Executable bits come from the worktree, which is why rtk-claude-hook
    # is tracked 755.
    ".local/bin/imgcat".source = link ".local/bin/imgcat";
    ".local/bin/rtk-claude-hook".source = link ".local/bin/rtk-claude-hook";
  };
}
