.PHONY: nvim install clean cleanHome

cwd := $(shell pwd)

install:
	mkdir -p ~/.config/{alacritty/{,themes},zellij}
	ln -sfn $(cwd)/zshrc ~/.zshrc
	ln -sfn $(cwd)/gitconfig ~/.gitconfig
	ln -sfn $(cwd)/gitignore ~/.gitignore
	ln -sfn $(cwd)/starship.toml ~/.config/starship.toml
	ln -sfn $(cwd)/alacritty.toml ~/.config/alacritty/alacritty.toml
	ln -sfn $(cwd)/alacritty-tokyo-night.toml ~/.config/alacritty/themes/tokyo-night.toml
	ln -sfn $(cwd)/config.kdl ~/.config/zellij/config.kdl

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
		~/.config/alacritty \
		~/.config/zellij

cleanHome:
	rm -rf ~/.DS_Store \
		~/.viminfo \
		~/.node_repl_history \
		~/.python_history \
		~/.lesshst \
		~/.yarnrc \
		~/.zprofile \
		~/.zcompdump \
		~/.zshenv \
		~/.profile \
		~/.DS_Store \
		~/.bash*
