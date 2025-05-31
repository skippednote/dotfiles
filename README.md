# Dotfiles

This repository contains my personal dotfiles and development environment configuration. It includes configurations for various tools and applications I use daily.

## Contents

- Shell configuration (`.zshrc`)
- Git configuration (`.gitconfig` and `.gitignore`)
- Terminal configuration (`skippednote.terminal`)
- Homebrew package management (`Brewfile`)
- Development tools and utilities

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

This will create symbolic links for the following files:
- `~/.zshrc`
- `~/.gitconfig`
- `~/.gitignore`

## Available Make Commands

- `make install`: Install dotfiles by creating symbolic links
- `make clean`: Remove symbolic links
- `make brewDump`: Update Brewfile with current Homebrew packages
- `make rustPackages`: Install Rust packages using cargo-binstall

## Included Software

### Homebrew Packages
- Development tools: `go`, `helm`, `hey`, `k9s`
- Shell enhancements: `starship`, `zsh-autosuggestions`
- Version management: `fnm`
- Utilities: `atuin`, `cargo-binstall`, `gh`, `uv`

### Applications
- Development: `cursor`, `orbstack`
- Productivity: `1password`, `arc`, `chatgpt`, `notion-calendar`, `raycast`, `rectangle`, `slack`, `zoom`
- Fonts: `font-fira-code-nerd-font`

### Rust Packages
- `bat`: Better cat
- `eza`: Modern ls
- `git-delta`: Better git diff
- `tokei`: Code statistics
- `zoxide`: Smarter cd

## Maintenance

To update the Brewfile with your current Homebrew packages:
```bash
make brewDump
```
