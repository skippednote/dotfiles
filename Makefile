cwd := $(shell pwd)

install:
	mkdir -p ~/.config/fish
	ln -sfn $(cwd)/config.fish ~/.config/fish/config.fish
	ln -sfn $(cwd)/gitconfig ~/.gitconfig
	ln -sfn $(cwd)/gitignore ~/.gitignore

clean:
	rm -rf ~/.config/fish \
		~/.gitconfig \
		~/.gitignore \

cleanHome:
	rm -rf ~/.DS_Store \
		~/.viminfo \
		~/.node_repl_history \
		~/.python_history \
		~/.lesshst \
		~/.yarnrc
