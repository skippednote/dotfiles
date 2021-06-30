#!/bin/bash

# create directories
mkdir $HOME/.zsh
mkdir -p $HOME/.config/nvim

# zsh plugins
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $HOME/.zsh/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions.git $HOME/.zsh/plugins/zsh-autosuggestions
git clone https://github.com/lukechilds/zsh-nvm.git $HOME/.zsh/plugins/zsh-nvm
git clone https://github.com/zsh-users/zsh-history-substring-search $HOME/.zsh/plugins/zsh-history-substring-search
git clone https://github.com/wfxr/forgit.git $HOME/.zsh/plugins/forgit

# symlink files to $HOME
ln -sfn $PWD/zshrc $HOME/.zshrc
ln -sfn $PWD/gitconfig $HOME/.gitconfig