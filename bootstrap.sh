#!/bin/bash

# create directories
mkdir $HOME/.zsh
mkdir -p $HOME/.config/nvim
mkdir -p $HOME/.config/kitty

# zsh plugins
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $HOME/.zsh/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions.git $HOME/.zsh/plugins/zsh-autosuggestions
git clone https://github.com/lukechilds/zsh-nvm.git $HOME/.zsh/plugins/zsh-nvm
git clone https://github.com/zsh-users/zsh-history-substring-search $HOME/.zsh/plugins/zsh-history-substring-search
git clone https://github.com/wfxr/forgit.git $HOME/.zsh/plugins/forgit

# kitty themes
git clone --depth 1 git@github.com:dexpota/kitty-themes.git ~/.config/kitty/kitty-themes

# symlink files to $HOME
ln -sfn $PWD/zshrc $HOME/.zshrc
ln -sfn $PWD/gitconfig $HOME/.gitconfig
ln -sfn $PWD/init.vim $HOME/.config/nvim/init.vim
ln -sfn $PWD/tmux.conf $HOME/.tmux.conf
ln -sfn $PWD/kitty.conf $HOME/.config/kitty/kitty.conf
ln -sfn $HOME/.config/kitty/kitty-themes/themes/gruvbox_dark.conf $HOME/.config/kitty/theme.conf

# linux
if [[ $OSTYPE == *"darwin"* ]]; then
  ln -sfn $PWD/Xresources $HOME/.Xresources
  ln -sfn $PWD/Xmodmap $HOME/.Xmodmap
fi

# macos
if [[ $OSTYPE == *"darwin"* ]]; then
  defaults write -g KeyRepeat -int 1
  defaults write -g InitialKeyRepeat -int 10
  defaults write com.apple.dock persistent-apps -array
  defaults write com.apple.dock persistent-others -array
  killall Dock
fi
