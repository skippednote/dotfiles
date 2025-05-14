.PHONY: install rustPackages

cwd := $(shell pwd)

install:
	ln -sfn $(cwd)/zshrc ~/.zshrc
	ln -sfn $(cwd)/gitconfig ~/.gitconfig
	ln -sfn $(cwd)/gitignore ~/.gitignore

clean:
	rm -rf ~/.zshrc \
		~/.gitconfig \
		~/.gitignore \

brewDump:
	brew bundle dump --force --cask --tap --mas --brew

rustPackages:
	cargo-binstall bat \
		eza \
		git-delta \
		tokei \
		zoxide