# Dotfiles

This repository contains my personal dotfiles and development environment configuration. It includes configurations for various tools and applications I use daily.

## Contents

- Shell configuration (`.zshrc`) with Go binary path, aliases, and modern shell tools
- Git configuration (`.gitconfig` and `.gitignore`) with delta pager and custom aliases
- Terminal configuration (`skippednote.terminal`)
- Homebrew package management (`Brewfile`)
- Development tools and utilities
- Custom scripts (optional `scripts/` directory)

## Prerequisites

- macOS
- Homebrew
- Make

## Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/skippednote/dotfiles.git
   cd dotfiles
   ```

2. Run the installation:
   ```bash
   make install
   ```

This will:
- Create backups of existing dotfiles (if any) to `~/.dotfiles-backup/`
- Create symbolic links for the following files:
  - `~/.zshrc`
  - `~/.gitconfig`
  - `~/.gitignore`
- Link scripts from `scripts/` directory to `~/.local/bin/` (if the directory exists)

## Terminal Theme

To install the terminal theme, open the `skippednote.terminal` file in Finder. This will open the Terminal app and prompt you to install the profile. Set it as your default profile in Terminal's preferences.

## Available Make Commands

- `make install`: Install dotfiles by creating symbolic links (includes automatic backup)
- `make clean`: Remove symbolic links
- `make backup`: Create backups of existing dotfiles
- `make check`: Verify dotfile installation status
- `make brewDump`: Update Brewfile with current Homebrew packages
- `make rustPackages`: Install Rust packages using cargo-binstall

## Included Software

### Homebrew Packages (Formulas)
- **Development tools**: `go`, `terraform`, `helm`, `k9s`
- **Testing/Performance tools**: `hey` (HTTP load testing), `k6` (performance testing)
- **Shell enhancements**: `starship` (prompt), `zsh-autosuggestions` (command suggestions)
- **Version management**: `fnm` (Node.js version manager)
- **Utilities**: 
  - `atuin` (command history search)
  - `cargo-binstall` (Rust binary installer)
  - `gh` (GitHub CLI)
  - `uv` (Python package manager)
  - `zola` (static site generator)

### Homebrew Packages (Casks)
- **Development**: `cursor`, `jetbrains-toolbox`, `orbstack`
- **Productivity**: `1password`, `granola`, `notion`, `notion-calendar`, `raycast`, `rectangle`, `slack`, `zoom`
- **AI Tools**: `chatgpt`
- **Media**: `vlc`, `insta360-link-controller`
- **Browsers**: `google-chrome`
- **Hardware**: `logi-options+`
- **Fonts**: `font-fira-code-nerd-font`

### Rust Packages
- `bat`: Better cat
- `eza`: Modern ls
- `git-delta`: Better git diff
- `jujutsu`: Git-compatible VCS
- `ripgrep`: Fast text search
- `tokei`: Code statistics
- `zoxide`: Smarter cd

## Shell Configuration Features

The `.zshrc` includes:

- **Environment Variables**:
  - `EDITOR` set to `cursor --wait` for Git and other tools
  - `GOPATH` configured for Go development
  - `_ZO_DOCTOR=0` to suppress zoxide warnings
  - `ATUIN_NOBIND=true` for custom keybindings

- **Tool Initializations**:
  - **Starship**: Modern, fast prompt
  - **Zoxide**: Smart directory navigation (`cd` → `z`)
  - **Atuin**: Enhanced command history search (bound to `^r`)
  - **FNM**: Fast Node.js version manager (auto-switches on directory change)
  - **Zsh-autosuggestions**: Type-ahead command suggestions
  - **SDKMAN**: Java/SDK version manager (if installed)

- **Useful aliases**: 
  - `l`, `a`, `ls`, `tree` - Enhanced directory listing with `eza`
  - `cd` - Alias to `z` (zoxide)
  - `cat` - Alias to `bat`
  - `g` - Git
  - `k` - Kubectl
  - `e` - Cursor editor
  - `ca` - Cursor agent
  - `d` - Quick access to dotfiles directory
  - `c` - Clear screen
  - `o` - Open files/folders
  - `tor` - WebTorrent CLI

- **Helper functions**: 
  - `mcd` - Make directory and cd into it
  - `cdr` - Change to git repository root

## Git Configuration Features

- **Delta**: Side-by-side diff viewer with syntax highlighting, line numbers, and decorations
- **SSH signing**: Configured with 1Password SSH agent
- **Automatic GPG signing**: Enabled for all commits using SSH format
- **Useful aliases**: 
  - `a` - add
  - `co` - checkout
  - `cob` - checkout -b
  - `cm` - commit -m
  - `cam` - commit --amend --no-edit
  - `d` - diff
  - `ds` - diff --staged
  - `s` - status
  - `lp` - Pretty log with graph
  - `lg` - One-line log with graph
  - And many more shortcuts for common operations

## Maintenance

To update the Brewfile with your current Homebrew packages:
```bash
make brewDump
```

To verify your installation:
```bash
make check
```

## Troubleshooting

### Scripts directory not found
If you see a warning about the scripts directory during installation, this is normal. The `scripts/` directory is optional. Create it and add your custom scripts if needed.

### Backup location
Backups are stored in `~/.dotfiles-backup/` and are created automatically during installation if existing dotfiles are found (non-symlinked files only).

### zoxide doctor warnings
The `_ZO_DOCTOR=0` environment variable disables zoxide's doctor warnings. This is intentional to keep the shell startup clean.
