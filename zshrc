export LANG=en_US.UTF-8
HYPHEN_INSENSITIVE="true"
ENABLE_CORRECTION="true"
COMPLETION_WAITING_DOTS="true"

autoload -U compinit && compinit
zmodload -i zsh/complist
setopt auto_cd
cdpath=($HOME $HOME/code $HOME/code/work $HOME/code/personal)

eval "$(starship init zsh)"

source $HOME/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source $HOME/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $HOME/.zsh/plugins/zsh-nvm/zsh-nvm.plugin.zsh

source $HOME/code/personal/dotfiles/aliases
source $HOME/code/personal/dotfiles/funcs
source $HOME/code/personal/dotfiles/paths

