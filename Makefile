cwd := $(shell pwd)

install:
	mkdir -p ~/.config/
	mkdir -p ~/.config/alacritty
	mkdir -p ~/.config/zellij
	mkdir -p ~/.config/k9s
	ln -sfn $(cwd)/zshrc ~/.zshrc
	ln -sfn $(cwd)/gitconfig ~/.gitconfig
	ln -sfn $(cwd)/gitignore ~/.gitignore
	ln -sfn $(cwd)/starship.toml ~/.config/starship.toml
	ln -sfn $(cwd)/alacritty.toml ~/.config/alacritty/alacritty.toml
	ln -sfn $(cwd)/config.kdl ~/.config/zellij/config.kdl
	ln -sfn $(cwd)/k9s.yaml ~/.config/k9s/config.yaml

clean:
	rm -rf ~/.zshrc \
		~/.gitconfig \
		~/.gitignore \
		~/.config/starship.toml

cleanHome:
	rm -rf ~/.DS_Store \
		~/.viminfo \
		~/.node_repl_history \
		~/.python_history \
		~/.lesshst \
		~/.yarnrc
