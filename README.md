### Installation
```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
cd ~
mkdir -p ~/code/personal/
cd ~/code/personal
git clone https://github.com/skippednote/dotfiles/
cd dotfiles
make
brew install
sudo bash -c 'echo $(which fish) >> /etc/shells'
chsh -s $(which fish)
open skippednote.terminal
sudo reboot now
```