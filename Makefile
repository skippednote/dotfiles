.PHONY: install clean brewDump rustPackages backup check

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

# Remove symbolic links
clean:
	@echo "Removing dotfile symlinks..."
	@rm -f ~/.zshrc ~/.gitconfig ~/.gitignore ~/.config/mise/config.toml
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

# Update Brewfile with current Homebrew packages
dump:
	brew bundle dump --force --cask --tap --mas --brew

