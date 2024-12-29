.PHONY: nvim install clean cleanHome

cwd := $(shell pwd)

install:
	mkdir -p ~/.config/zellij
	ln -sfn $(cwd)/zshrc ~/.zshrc
	ln -sfn $(cwd)/gitconfig ~/.gitconfig
	ln -sfn $(cwd)/gitignore ~/.gitignore
	ln -sfn $(cwd)/starship.toml ~/.config/starship.toml
	ln -sfn $(cwd)/config.kdl ~/.config/zellij/config.kdl
	ln -sfn $(cwd)/ghostty ~/Library/Application\ Support/com.mitchellh.ghostty/config

nvim:
	rm -rf ~/.config/nvim
	ln -sfn $(cwd)/nvim ~/.config/nvim
	curl -L https://github.com/neovim/neovim/releases/download/stable/nvim-macos-arm64.tar.gz -o /tmp/nvim-macos-arm64.tar.gz
	sudo tar -xzf /tmp/nvim-macos-arm64.tar.gz -C /usr/local/nvim

clean:
	rm -rf ~/.zshrc \
		~/.gitconfig \
		~/.gitignore \
		~/.config/starship.toml \
		~/.config/nvim \
		~/.config/zellij

cleanHome:
	rm -rf ~/.DS_Store \
		~/.viminfo \
		~/.node_repl_history \
		~/.python_history \
		~/.lesshst \
		~/.yarnrc 
		~/.zcompdump \
		~/.zshenv \
		~/.profile \
		~/.DS_Store \
		~/.bash*

arkade:
	curl -sLS https://get.arkade.dev | sudo sh -s
	arkade get \
		helm \
		k9s \
		kind \
		kubectx

brewDump:
	brew bundle dump --force --cask --tap --mas --brew
