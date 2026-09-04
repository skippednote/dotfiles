# Dotfile placement.
#
# Every link is an out-of-store symlink into the worktree rather than a copy
# into /nix/store, because several of these files are written by the tools
# that read them: .zshrc (LM Studio appends a PATH block), .gitconfig (gh
# auth writes credential helpers), .ssh/config (the Upsun CLI writes a cert
# block) and nvim's lazy-lock.json (lazy.nvim). Store copies are read-only
# and would break them.
#
# Only .config/nvim is linked as a directory. Everything else is linked file
# by file, because the directories involved hold state this repo must not
# own: ~/.ssh has private keys, ~/.claude has daemon logs and caches,
# ~/.codex has auth and state, ~/.local/bin has hand-installed binaries.
{
  config,
  user,
  hostname,
  ...
}:

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

    # Lets git verify SSH signatures, not just create them.
    ".config/git/allowed_signers".source = link ".config/git/allowed_signers";

    # The machine-specific half of .gitconfig, which includes this path.
    # Signing needs 1Password and it is only installed on skippednote.
    ".config/git/host.conf".source = link ".config/git/host-${hostname}.conf";

    # Application configs that are hand-authored text. Tracked as single
    # files, never whole directories: ~/.config/herdr also holds session
    # state and logs, and ~/.config/zed/prompts is an LMDB database.
    ".config/zed/settings.json".source = link ".config/zed/settings.json";
    ".config/atuin/config.toml".source = link ".config/atuin/config.toml";
    ".config/herdr/config.toml".source = link ".config/herdr/config.toml";
    ".config/mise/config.toml".source = link ".config/mise/config.toml";
    # .config/gh/config.yml is deliberately not linked: gh rewrites the whole
    # file on any config change, and the only content that was not a default
    # was one alias. Recreate it with `gh alias set co 'pr checkout'`.
    ".config/ai/working-preferences.md".source = link ".config/ai/working-preferences.md";

    # The whole LazyVim tree, including the lockfile nvim rewrites.
    ".config/nvim".source = link ".config/nvim";

    # Agents. settings.local.json, config.toml, auth and state stay unmanaged.
    # .claude/settings.json is not linked: Claude Code rewrites it, and it
    # carries machine-specific state (enabled plugins, auto-mode environment).
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
