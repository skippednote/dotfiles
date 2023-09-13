cwd := $(shell pwd)

install:
	mkdir -p ~/.config/fish
	ln -sfn $(cwd)/config.fish ~/.config/fish/config.fish
	ln -sfn $(cwd)/gitconfig ~/.gitconfig

clean:
	rm -rf ~/.config/fish/config.fish \
		~/.gitconfig