#!/bin/bash

set -e  # Exit on error

echo "=== Dotfiles + Dependencies Setup Script ==="

#          ╭──────────────────────────────────────────────────────────╮
#          │                       Dependencies                       │
#          ╰──────────────────────────────────────────────────────────╯
declare -a ARCH_PACKAGES=("stow" "zsh" "git" "neovim" "alacritty" "fd" "ripgrep" "fzf" "lazygit" "gcc" "nodejs" "feh" "i3status-rust")
declare -a DEBIAN_PACKAGES=("stow" "zsh" "git" "neovim" "alacritty" "fd-find" "ripgrep" "fzf" "lazygit" "gcc" "nodejs" "feh" "i3status-rust")
declare -a FEDORA_PACKAGES=DEBIAN_PACKAGES

# ── Detect and install ────────────────────────────────────────────────
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if command -v apt &> /dev/null; then
        sudo apt update
        sudo apt install -y "${DEBIAN_PACKAGES[@]}"
    elif command -v pacman &> /dev/null; then
        sudo pacman -Sy --noconfirm "${ARCH_PACKAGES[@]}"
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y "${FEDORA_PACKAGES[@]}"
    else
        echo "Unsupported package manager. Please install manually."
        exit 1
    fi
else 
    echo "Non-Linux OS I can't help you..."
    exit 1
fi

# ── install oh-my-zsh ─────────────────────────────────────────────────
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" --unattended

#          ╭──────────────────────────────────────────────────────────╮
#          │                          Config                          │
#          ╰──────────────────────────────────────────────────────────╯

# ── Set up XDG_CONFIG_HOME ────────────────────────────────────────────
export XDG_CONFIG_HOME="$HOME"/.config
mkdir -p "$XDG_CONFIG_HOME"

# ── dotfiles ──────────────────────────────────────────────────────────
echo "Running GNU Stow to create symlinks..."
stow -v --adopt .

# ── nvim ──────────────────────────────────────────────────────────────
if [ ! -d "$XDG_CONFIG_HOME/nvim" ]; then
    echo "Cloning nvim config from repo..."
    git clone https://github.com/timo-y/nvim.git "$XDG_CONFIG_HOME"/nvim
    echo "Nvim config cloned."
else
    echo "Nvim config already exists, skipping clone."
fi

#          ╭──────────────────────────────────────────────────────────╮
#          │                        Nerd Fonts                        │
#          ╰──────────────────────────────────────────────────────────╯
declare -a NERD_FONTS=("GeistMono")
mkdir -p ~/.local/share/fonts

# ── Download and install each font ────────────────────────────────────
for font in "${NERD_FONTS[@]}"; do
    echo "Downloading $font Nerd Font..."
    
    # Define zip file path
    zip_file="$font.zip"
    zip_path="$HOME/.local/share/fonts/$zip_file"
    
    # Download the font
    curl -L "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/$zip_file" -o "$zip_path"
    
    # Unzip into the fonts directory
    unzip -o "$zip_path" -d "$HOME/.local/share/fonts"
    
    # Remove the zip file
    rm "$zip_path"
done

# ── Refresh font cache ────────────────────────────────────────────────
fc-cache -fv

echo "Nerd fonts installed and font cache updated."

echo "=== Setup complete! ==="
echo "Please restart your shell or run 'source ~/.bashrc' or 'source ~/.zshrc'".

