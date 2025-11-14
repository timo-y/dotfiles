#!/bin/bash

set -e  # Exit on error

echo "=== Dotfiles + Dependencies Setup Script ==="

#          ╭──────────────────────────────────────────────────────────╮
#          │                       Dependencies                       │
#          ╰──────────────────────────────────────────────────────────╯
declare -a ARCH_PACKAGES=("stow" "zsh" "git" "neovim" "alacritty" "fd" "ripgrep" "fzf" "lazygit" "gcc" "nodejs")
declare -a DEBIAN_PACKAGES=("stow" "zsh" "git" "neovim" "alacritty" "fd-find" "ripgrep" "fzf" "lazygit" "gcc" "nodejs")
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
declare NERD_FONTS=("GeistMono")

mkdir -p ~/.local/share/fonts

# ── download and install nerd fonts ───────────────────────────────────
for font in $NERD_FONTS; do
    echo "Downloading $font..."
    mkdir -p ~/.local/share/fonts
    curl -L https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/$font.zip -o ~/.local/share/fonts/$font.zip
    unzip ~/.local/share/fonts/$font.zip -d ~/.local/share/fonts
done

# ── refresh font cache ────────────────────────────────────────────────
fc-cache -f -v


echo "=== Setup complete! ==="
echo "Please restart your shell or run 'source ~/.bashrc' or 'source ~/.zshrc'".

