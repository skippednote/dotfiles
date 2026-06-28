.PHONY: install clean clean-tools clean-all brew-clean brew-clean-force backup check lazyvim lazyvim-starter lazyvim-link lazyvim-force dump defaults bootstrap bootstrap-tools require-chezmoi uv-tools

# Get the current working directory
cwd := $(shell pwd)
# Define the local bin directory
LOCAL_BIN := $(HOME)/.local/bin
export PATH := $(LOCAL_BIN):$(PATH)
NVIM_CONFIG_DIR := $(HOME)/.config/nvim
LAZYVIM_REPO := https://github.com/LazyVim/starter.git
CHEZMOI_SOURCE := $(cwd)/home

# Install dotfiles by applying the chezmoi source state in ./home.
install: backup require-chezmoi
	@echo "Applying dotfiles with chezmoi..."
	@chezmoi --source="$(CHEZMOI_SOURCE)" --destination="$(HOME)" apply --force
	@echo "Installation complete!"

require-chezmoi:
	@if ! command -v chezmoi >/dev/null 2>&1; then \
		echo "chezmoi is required. Run \`make bootstrap-tools\` first."; \
		exit 1; \
	fi

# Install the tools needed before dotfiles and mise-managed CLIs can be applied.
bootstrap-tools:
	@mkdir -p $(LOCAL_BIN)
	@if ! command -v chezmoi >/dev/null 2>&1; then \
		echo "Installing chezmoi to $(LOCAL_BIN)..."; \
		sh -c "$$(curl -fsLS https://get.chezmoi.io)" -- -b "$(LOCAL_BIN)"; \
	else \
		echo "chezmoi already installed"; \
	fi
	@if [ ! -x "$(LOCAL_BIN)/mise" ]; then \
		echo "Installing mise to $(LOCAL_BIN)..."; \
		curl -fsSL https://mise.run | MISE_INSTALL_PATH="$(LOCAL_BIN)/mise" sh; \
	else \
		echo "mise already installed in $(LOCAL_BIN)"; \
	fi

# Apply macOS defaults
defaults:
	@bash $(cwd)/defaults.sh

# Full bootstrap for a fresh Mac
bootstrap:
	@bash $(cwd)/bootstrap.sh

# Create backups of existing dotfiles
backup:
	@echo "Creating backups..."
	@mkdir -p $(HOME)/.dotfiles-backup
	@if [ -f ~/.zshrc ] && [ ! -L ~/.zshrc ]; then \
		cp ~/.zshrc $(HOME)/.dotfiles-backup/zshrc.backup && echo "? Backed up .zshrc"; \
	fi
	@if [ -f ~/.gitconfig ] && [ ! -L ~/.gitconfig ]; then \
		cp ~/.gitconfig $(HOME)/.dotfiles-backup/gitconfig.backup && echo "? Backed up .gitconfig"; \
	fi
	@if [ -f ~/.gitignore ] && [ ! -L ~/.gitignore ]; then \
		cp ~/.gitignore $(HOME)/.dotfiles-backup/gitignore.backup && echo "? Backed up .gitignore"; \
	fi
	@if [ -f ~/.config/mise/config.toml ] && [ ! -L ~/.config/mise/config.toml ]; then \
		cp ~/.config/mise/config.toml $(HOME)/.dotfiles-backup/mise.config.backup && echo "? Backed up mise config"; \
	fi
	@if [ -f ~/.config/starship.toml ] && [ ! -L ~/.config/starship.toml ]; then \
		cp ~/.config/starship.toml $(HOME)/.dotfiles-backup/starship.toml.backup && echo "? Backed up starship config"; \
	fi
	@if [ -f ~/.config/cmux/cmux.json ] && [ ! -L ~/.config/cmux/cmux.json ]; then \
		mkdir -p $(HOME)/.dotfiles-backup/cmux; \
		cp ~/.config/cmux/cmux.json $(HOME)/.dotfiles-backup/cmux/cmux.json.backup && echo "? Backed up cmux config"; \
	fi
	@if [ -f ~/.config/ai/working-preferences.md ] && [ ! -L ~/.config/ai/working-preferences.md ]; then \
		mkdir -p $(HOME)/.dotfiles-backup/ai; \
		cp ~/.config/ai/working-preferences.md $(HOME)/.dotfiles-backup/ai/working-preferences.md.backup && echo "? Backed up working-preferences"; \
	fi
	@if [ -f ~/.claude/settings.json ] && [ ! -L ~/.claude/settings.json ]; then \
		mkdir -p $(HOME)/.dotfiles-backup/claude; \
		cp ~/.claude/settings.json $(HOME)/.dotfiles-backup/claude/settings.json.backup && echo "? Backed up Claude settings"; \
	fi
	@if [ -f ~/.claude/CLAUDE.md ] && [ ! -L ~/.claude/CLAUDE.md ]; then \
		mkdir -p $(HOME)/.dotfiles-backup/claude; \
		cp ~/.claude/CLAUDE.md $(HOME)/.dotfiles-backup/claude/CLAUDE.md.backup && echo "? Backed up Claude CLAUDE.md"; \
	fi
	@if [ -f ~/.claude/RTK.md ] && [ ! -L ~/.claude/RTK.md ]; then \
		mkdir -p $(HOME)/.dotfiles-backup/claude; \
		cp ~/.claude/RTK.md $(HOME)/.dotfiles-backup/claude/RTK.md.backup && echo "? Backed up Claude RTK.md"; \
	fi
	@if [ -f ~/.claude/AGENTS.md ] && [ ! -L ~/.claude/AGENTS.md ]; then \
		mkdir -p $(HOME)/.dotfiles-backup/claude; \
		cp ~/.claude/AGENTS.md $(HOME)/.dotfiles-backup/claude/AGENTS.md.backup && echo "? Backed up Claude AGENTS.md"; \
	fi
	@if [ -f ~/.codex/AGENTS.md ] && [ ! -L ~/.codex/AGENTS.md ]; then \
		mkdir -p $(HOME)/.dotfiles-backup/codex; \
		cp ~/.codex/AGENTS.md $(HOME)/.dotfiles-backup/codex/AGENTS.md.backup && echo "? Backed up Codex AGENTS.md"; \
	fi
	@if [ -f ~/.codex/RTK.md ] && [ ! -L ~/.codex/RTK.md ]; then \
		mkdir -p $(HOME)/.dotfiles-backup/codex; \
		cp ~/.codex/RTK.md $(HOME)/.dotfiles-backup/codex/RTK.md.backup && echo "? Backed up Codex RTK.md"; \
	fi
	@if [ -f ~/.codex/hooks.json ] && [ ! -L ~/.codex/hooks.json ]; then \
		mkdir -p $(HOME)/.dotfiles-backup/codex; \
		cp ~/.codex/hooks.json $(HOME)/.dotfiles-backup/codex/hooks.json.backup && echo "? Backed up Codex hooks.json"; \
	fi
	@if [ -f $(HOME)/.ssh/config ] && [ ! -L $(HOME)/.ssh/config ]; then \
		cp $(HOME)/.ssh/config $(HOME)/.dotfiles-backup/ssh_config.backup && echo "? Backed up SSH config"; \
	fi
	@if [ -f ~/.config/nvim/lua/config/lazy.lua ] && [ ! -L ~/.config/nvim/lua/config/lazy.lua ]; then \
		mkdir -p $(HOME)/.dotfiles-backup/nvim; \
		cp ~/.config/nvim/lua/config/lazy.lua $(HOME)/.dotfiles-backup/nvim/lazy.lua.backup && echo "? Backed up nvim lua/config/lazy.lua"; \
	fi

# Remove files managed by this repo. This is intentionally explicit.
clean:
	@echo "Removing managed dotfiles..."
	@rm -f ~/.zshrc ~/.gitconfig ~/.gitignore ~/.config/mise/config.toml ~/.config/starship.toml
	@rm -f ~/.config/cmux/cmux.json ~/.config/ai/working-preferences.md
	@rm -f ~/.claude/settings.json ~/.claude/CLAUDE.md ~/.claude/AGENTS.md ~/.claude/RTK.md
	@rm -f ~/.codex/AGENTS.md ~/.codex/RTK.md ~/.codex/hooks.json
	@rm -f ~/.config/nvim/lua/config/lazy.lua
	@rm -f ~/.ssh/config
	@rm -f $(HOME)/.config/gh/config.yml
	@rm -f $(HOME)/Library/LaunchAgents/com.skippednote.capslock-to-control.plist
	@rm -f $(LOCAL_BIN)/imgcat $(LOCAL_BIN)/rtk-claude-hook
	@echo "Clean complete!"

# Remove only the standalone bootstrap tools installed by bootstrap-tools.
clean-tools:
	@echo "Removing bootstrap tools..."
	@rm -f $(LOCAL_BIN)/chezmoi $(LOCAL_BIN)/mise
	@echo "Bootstrap tools removed."

# Show Homebrew packages and casks that are not declared in Brewfile.
brew-clean:
	@brew bundle cleanup --file="$(cwd)/Brewfile"

# Remove Homebrew packages and casks that are not declared in Brewfile.
brew-clean-force:
	@brew bundle cleanup --file="$(cwd)/Brewfile" --force

# Remove managed dotfiles, standalone bootstrap tools, and undeclared Homebrew packages/casks.
clean-all: clean clean-tools brew-clean-force

# Verify dotfile installation status
check:
	@echo "Checking dotfile installation..."
	@if [ -f ~/.zshrc ]; then \
		echo "OK .zshrc exists"; \
	else \
		echo "MISSING .zshrc"; \
	fi
	@if [ -f ~/.gitconfig ]; then \
		echo "OK .gitconfig exists"; \
	else \
		echo "MISSING .gitconfig"; \
	fi
	@if [ -f ~/.gitignore ]; then \
		echo "OK .gitignore exists"; \
	else \
		echo "MISSING .gitignore"; \
	fi
	@if [ -f ~/.config/mise/config.toml ]; then \
		echo "OK mise config exists"; \
	else \
		echo "MISSING mise config"; \
	fi
	@if [ -f ~/.config/starship.toml ]; then \
		echo "OK starship config exists"; \
	else \
		echo "MISSING starship config"; \
	fi
	@if [ -f ~/.config/cmux/cmux.json ]; then \
		echo "OK cmux config exists"; \
	else \
		echo "MISSING cmux config"; \
	fi
	@if [ -f ~/.config/ai/working-preferences.md ]; then \
		echo "OK working-preferences exists"; \
	else \
		echo "MISSING working-preferences"; \
	fi
	@if [ -f ~/.claude/settings.json ]; then \
		echo "OK Claude settings exist"; \
	else \
		echo "MISSING Claude settings"; \
	fi
	@if [ -f ~/.claude/CLAUDE.md ]; then \
		echo "OK Claude CLAUDE.md exists"; \
	else \
		echo "MISSING Claude CLAUDE.md"; \
	fi
	@if [ -f ~/.claude/RTK.md ]; then \
		echo "OK Claude RTK.md exists"; \
	else \
		echo "MISSING Claude RTK.md"; \
	fi
	@if [ -f ~/.claude/AGENTS.md ]; then \
		echo "OK Claude AGENTS.md exists"; \
	else \
		echo "MISSING Claude AGENTS.md"; \
	fi
	@if [ -f ~/.codex/AGENTS.md ]; then \
		echo "OK Codex AGENTS.md exists"; \
	else \
		echo "MISSING Codex AGENTS.md"; \
	fi
	@if [ -f ~/.codex/RTK.md ]; then \
		echo "OK Codex RTK.md exists"; \
	else \
		echo "MISSING Codex RTK.md"; \
	fi
	@if [ -f ~/.codex/hooks.json ]; then \
		echo "OK Codex hooks.json exists"; \
	else \
		echo "MISSING Codex hooks.json"; \
	fi
	@if [ -L ~/.config/nvim/lua/config/lazy.lua ]; then \
		echo "OK lazy.lua (nvim) is linked"; \
	elif [ -f ~/.config/nvim/lua/config/lazy.lua ]; then \
		echo "OK lazy.lua exists but is not linked"; \
	else \
		echo "MISSING lazy.lua (run \`make lazyvim\`)"; \
	fi
	@if [ -f $(HOME)/.ssh/config ]; then \
		echo "OK SSH config exists"; \
	else \
		echo "MISSING SSH config"; \
	fi
	@if [ -f $(HOME)/.config/gh/config.yml ]; then \
		echo "OK gh config exists"; \
	else \
		echo "MISSING gh config"; \
	fi
	@if [ -f $(LOCAL_BIN)/imgcat ]; then \
		echo "OK imgcat exists"; \
	else \
		echo "MISSING imgcat"; \
	fi
	@if [ -f $(LOCAL_BIN)/rtk-claude-hook ]; then \
		echo "OK rtk-claude-hook exists"; \
	else \
		echo "MISSING rtk-claude-hook"; \
	fi

# Link the dotfiles-managed LazyVim config override.
lazyvim-link:
	@if [ -f "$(cwd)/lazy.lua" ]; then \
		mkdir -p $(NVIM_CONFIG_DIR)/lua/config; \
		ln -sfn $(cwd)/lazy.lua $(NVIM_CONFIG_DIR)/lua/config/lazy.lua && echo "? Linked lazy.lua (nvim)"; \
	else \
		echo "? lazy.lua not found in dotfiles"; \
	fi

# Install or update the LazyVim starter config without overwriting an unrelated Neovim setup.
lazyvim-starter:
	@if ! command -v git >/dev/null 2>&1; then \
		echo "? git is required to install LazyVim"; \
		exit 1; \
	fi
	@if [ -d "$(NVIM_CONFIG_DIR)/.git" ]; then \
		remote_url="$$(git -C "$(NVIM_CONFIG_DIR)" remote get-url origin 2>/dev/null || true)"; \
		if [ "$$remote_url" = "$(LAZYVIM_REPO)" ] || [ "$$remote_url" = "git@github.com:LazyVim/starter.git" ]; then \
			echo "Updating LazyVim starter..."; \
			git -C "$(NVIM_CONFIG_DIR)" pull --ff-only; \
		else \
			echo "? Refusing to overwrite existing Neovim config at $(NVIM_CONFIG_DIR)"; \
			echo "  Move it aside or run \`make lazyvim-force\` to back it up and replace it."; \
			exit 1; \
		fi; \
	elif [ -e "$(NVIM_CONFIG_DIR)" ] && [ -n "$$(find "$(NVIM_CONFIG_DIR)" -mindepth 1 -maxdepth 1 2>/dev/null)" ]; then \
		echo "? Refusing to overwrite existing Neovim config at $(NVIM_CONFIG_DIR)"; \
		echo "  Move it aside or run \`make lazyvim-force\` to back it up and replace it."; \
		exit 1; \
	else \
		echo "Installing LazyVim starter..."; \
		rm -rf "$(NVIM_CONFIG_DIR)"; \
		git clone --depth=1 "$(LAZYVIM_REPO)" "$(NVIM_CONFIG_DIR)"; \
	fi

# Back up the current Neovim config and replace it with a fresh LazyVim starter checkout.
lazyvim-force: backup
	@if ! command -v git >/dev/null 2>&1; then \
		echo "? git is required to install LazyVim"; \
		exit 1; \
	fi
	@if [ -e "$(NVIM_CONFIG_DIR)" ]; then \
		backup_dir="$(HOME)/.dotfiles-backup/nvim-$$(date +%Y%m%d-%H%M%S)"; \
		mv "$(NVIM_CONFIG_DIR)" "$$backup_dir"; \
		echo "? Backed up Neovim config to $$backup_dir"; \
	fi
	@echo "Installing LazyVim starter..."
	@git clone --depth=1 "$(LAZYVIM_REPO)" "$(NVIM_CONFIG_DIR)"
	@$(MAKE) --no-print-directory lazyvim-link
	@echo "LazyVim installed! Run \`nvim\` to start (requires Neovim)."

# Install or update LazyVim, then link the dotfiles-managed config override.
lazyvim: lazyvim-starter lazyvim-link
	@echo "LazyVim is ready. Run \`nvim\` to start (requires Neovim)."

# Update Brewfile with current Homebrew packages
dump:
	brew bundle dump --force --cask --tap --mas --brew

# Install global uv-managed CLI tools (not tracked by mise).
uv-tools:
	@bash $(cwd)/uv-tools.sh
