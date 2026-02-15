.PHONY: install clean brewDump rustPackages backup check lazyvim

# Get the current working directory
cwd := $(shell pwd)
# Define the local bin directory
LOCAL_BIN := $(HOME)/.local/bin

# Install dotfiles by creating symbolic links
install: backup
	@echo "Installing dotfiles..."
	@mkdir -p $(LOCAL_BIN)
	@mkdir -p ~/.config/mise
	@ln -sfn $(cwd)/zshrc ~/.zshrc && echo "? Linked .zshrc"
	@ln -sfn $(cwd)/gitconfig ~/.gitconfig && echo "? Linked .gitconfig"
	@ln -sfn $(cwd)/gitignore ~/.gitignore && echo "? Linked .gitignore"
	@ln -sfn $(cwd)/mise.toml ~/.config/mise/config.toml && echo "? Linked mise config"
	@mkdir -p ~/.config
	@ln -sfn $(cwd)/starship.toml ~/.config/starship.toml && echo "? Linked starship config"
	@if [ -f "$(cwd)/lazy.lua" ]; then \
		mkdir -p ~/.config/nvim/lua/config; \
		ln -sfn $(cwd)/lazy.lua ~/.config/nvim/lua/config/lazy.lua && echo "? Linked lazy.lua (nvim)"; \
	else \
		echo "? lazy.lua not found in dotfiles"; \
	fi
	@if [ -d "$(cwd)/scripts" ]; then \
		ln -sfn $(cwd)/scripts/* $(LOCAL_BIN)/ && echo "? Linked scripts"; \
	else \
		echo "? No scripts directory found, skipping..."; \
	fi
	@echo "Installation complete!"

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
	@if [ -f ~/.config/nvim/lua/config/lazy.lua ] && [ ! -L ~/.config/nvim/lua/config/lazy.lua ]; then \
		mkdir -p $(HOME)/.dotfiles-backup/nvim; \
		cp ~/.config/nvim/lua/config/lazy.lua $(HOME)/.dotfiles-backup/nvim/lazy.lua.backup && echo "? Backed up nvim lua/config/lazy.lua"; \
	fi

# Remove symbolic links
clean:
	@echo "Removing dotfile symlinks..."
	@rm -f ~/.zshrc ~/.gitconfig ~/.gitignore ~/.config/mise/config.toml ~/.config/starship.toml
	@rm -f ~/.config/nvim/lua/config/lazy.lua
	@echo "Clean complete!"

# Verify dotfile installation status
check:
	@echo "Checking dotfile installation..."
	@if [ -L ~/.zshrc ]; then \
		echo "? .zshrc is linked"; \
	else \
		echo "? .zshrc is not linked"; \
	fi
	@if [ -L ~/.gitconfig ]; then \
		echo "? .gitconfig is linked"; \
	else \
		echo "? .gitconfig is not linked"; \
	fi
	@if [ -L ~/.gitignore ]; then \
		echo "? .gitignore is linked"; \
	else \
		echo "? .gitignore is not linked"; \
	fi
	@if [ -L ~/.config/mise/config.toml ]; then \
		echo "? mise config is linked"; \
	else \
		echo "? mise config is not linked"; \
	fi
	@if [ -L ~/.config/starship.toml ]; then \
		echo "? starship config is linked"; \
	else \
		echo "? starship config is not linked"; \
	fi
	@if [ -L ~/.config/nvim/lua/config/lazy.lua ]; then \
		echo "? lazy.lua (nvim) is linked"; \
	elif [ -f ~/.config/nvim/lua/config/lazy.lua ]; then \
		echo "? lazy.lua exists but is not linked (run \`make install\` to link)"; \
	else \
		echo "? lazy.lua not found (run \`make lazyvim\` then \`make install\`)"; \
	fi

# Install LazyVim (Neovim config) at ~/.config/nvim. Run \`make install\` afterward to symlink lazy.lua from dotfiles.
lazyvim: backup
	@echo "Installing LazyVim..."
	@rm -rf ~/.config/nvim
	@git clone --depth=1 https://github.com/LazyVim/starter.git ~/.config/nvim
	@echo "LazyVim installed! Run \`make install\` to link lazy.lua from dotfiles, then \`nvim\` to start (requires Neovim)."

# Update Brewfile with current Homebrew packages
dump:
	brew bundle dump --force --cask --tap --mas --brew

