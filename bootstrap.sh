#!/bin/bash

# create directories
mkdir -p $HOME/.config/fish

# symlink files to $HOME
ln -sfn $PWD/config.fish $HOME/.config/fish/config.fish
ln -sfn $PWD/gitconfig $HOME/.gitconfig

# Install fisher and plugins
curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher
fisher install jorgebucaran/fisher
fisher install jorgebucaran/nvm.fish
fisher install jethrokuan/z
