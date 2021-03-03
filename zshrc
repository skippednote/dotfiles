export LANG=en_US.UTF-8

export HISTFILESIZE=1000000000
export HISTSIZE=1000000000
export SAVEHIST=1000000000
export HISTFILE="$HOME/.zsh_history"
setopt extended_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_verify
setopt share_history
setopt inc_append_history

setopt auto_cd
cdpath=($HOME $HOME/code $HOME/code/work $HOME/code/personal)

eval "$(starship init zsh)"

source $HOME/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source $HOME/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $HOME/.zsh/plugins/zsh-nvm/zsh-nvm.plugin.zsh
source $HOME/.zsh/plugins/forgit/forgit.plugin.zsh

source $HOME/code/personal/dotfiles/aliases
source $HOME/code/personal/dotfiles/funcs
source $HOME/code/personal/dotfiles/paths

autoload -U compinit && compinit
zmodload -i zsh/complist
