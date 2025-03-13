#!/bin/bash

# Install packages
echo "Installing packages..."
sudo pacman -S alacritty wget zip unzip base-devel neovim bat zsh tmux kubectl helm podman go jq yq
read -p "Press key to continue...\n" -n1 -s

# Install lsd
echo "Installing lsd..."
wget https://github.com/lsd-rs/lsd/releases/download/v1.1.5/lsd-v1.1.5-x86_64-unknown-linux-musl.tar.gz
tar -xvf lsd-v1.1.5-x86_64-unknown-linux-musl.tar.gz
chmod +x ./lsd-v1.1.5-x86_64-unknown-linux-musl/lsd
sudo mv ./lsd-v1.1.5-x86_64-unknown-linux-musl/lsd /usr/local/bin/
rm -rf ./lsd-v1.1.5-x86_64-unknown-linux-musl/
rm lsd-v1.1.5-x86_64-unknown-linux-musl.tar.gz
read -p "Press key to continue...\n" -n1 -s

# Install kind
echo "Installing kind..."
[ $(uname -m) = x86_64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.27.0/kind-$(uname)-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
read -p "Press key to continue...\n" -n1 -s

# Install NVM
echo "Installing nvm..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.2/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
nvm install v22.14.0
read -p "Press key to continue...\n" -n1 -s

# Install Rust
echo "Installing Rust..."
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
#read -p "Press key to continue...\n" -n1 -s

# Install fonts
echo "Installing nerd fonts..."
cd ./.fonts
unzip fonts.zip
mkdir -p $HOME/.fonts
cp fonts/* $HOME/.fonts/
rm -rf ./fonts/
fc-cache --force
cd ..
read -p "Press key to continue...\n" -n1 -s

# bat setup
echo "Set up bat..."
mkdir -p "$(bat --config-dir)/themes"
wget -P "$(bat --config-dir)/themes" https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Latte.tmTheme
wget -P "$(bat --config-dir)/themes" https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Frappe.tmTheme
wget -P "$(bat --config-dir)/themes" https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Macchiato.tmTheme
wget -P "$(bat --config-dir)/themes" https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Mocha.tmTheme
bat cache --build
bat --list-themes
mkdir -p $HOME/.config/bat
cp ./.config/bat/config $HOME/.config/bat/config
read -p "Press key to continue...\n" -n1 -s

# tmux setup
echo "Set up tmux..."
mkdir -p ~/.config/tmux/plugins/catppuccin
git clone -b v2.1.2 https://github.com/catppuccin/tmux.git ~/.config/tmux/plugins/catppuccin/tmux
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
cp .tmux.conf $HOME/.tmux.conf
read -p "Press key to continue...\n" -n1 -s

# oh-my-zsh setup
read -p "On oh-my-zsh installation done and setting up zsh as the default shell, type exit in the shell to continue with the process in bash. Press key to continue...\n" -n1 -s
echo "Set up zsh..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
git clone https://github.com/zsh-users/zsh-history-substring-search ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-history-substring-search
git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git \
  ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fast-syntax-highlighting

cp ./.zshrc $HOME/.zshrc
read -p "Press key to continue...\n" -n1 -s

# nvim setup
echo "Set up nvim..."
git clone --depth 1 https://github.com/wbthomason/packer.nvim\
 ~/.local/share/nvim/site/pack/packer/start/packer.nvim
mkdir -p $HOME/.config/nvim
cp ./.config/nvim/init.lua $HOME/.config/nvim/

# alacritty setup
echo "Setup alacritty..."
mkdir -p $HOME/.config/alacritty
curl -LO --output-dir ~/.config/alacritty https://github.com/catppuccin/alacritty/raw/main/catppuccin-mocha.toml
cp ./.config/alacritty/alacritty.toml $HOME/.config/alacritty/
read -p "Press key to continue...\n" -n1 -s

echo "Completed!"
