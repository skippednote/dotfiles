starship init fish | source

alias l="exa -lh --git"
alias a="exa -lha --git"
alias c='clear'
alias v="nvim"
alias vi="echo 'Use v'"
alias o="open"
alias ls="exa --git"
alias tree="ls --tree"
alias cat="bat"
alias k="kubectl"
alias d="cd ~/code/personal/dotfiles"
alias reload="source ~/.zshrc"
alias path='echo $PATH | tr ":" "\n"'
alias genkeys='ssh-keygen -t ed25519 -C "skippednote@gmail.com" '
alias copykeys='cat ~/.ssh/id_ed25519.pub | pbcopy'
alias vu='vagrant up'
alias vs='vagrant ssh'
alias vh='vagrant halt'
alias vp='vagrant provision'
alias yt='docker run --rm -u (id -u):(id -g) -v (PWD):/data vimagick/youtube-dl'
alias g="git"
alias grr="git remote remove"
alias gra="git remote add"
alias createdrupal="composer create-project drupal/recommended-project"

function mcd
  mkdir $argv[1]
  cd $argv[1]
end

function skipCyPup
  set -gx CYPRESS_INSTALL_BINARY 0
  set -gx PUPPETEER_SKIP_CHROMIUM_DOWNLOAD 0
end


set -gx BAT_THEME Dracula
set -g fish_user_paths /usr/local/nvim/bin $HOME/.platformsh/bin $fish_user_paths
