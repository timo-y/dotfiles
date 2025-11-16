#!/bin/bash

set -e  # Exit on error

echo "=== Dotfiles + Dependencies Setup Script ==="

# ── Ask installation type ─────────────────────────────────────────────
read -p "Is this a desktop installation? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    IS_DESKTOP=true
    echo "Setting up for desktop environment..."
else
    IS_DESKTOP=false
    echo "Setting up for server/headless environment..."
fi

#          ╭──────────────────────────────────────────────────────────╮
#          │                       Dependencies                       │
#          ╰──────────────────────────────────────────────────────────╯

# Core packages (always installed)
declare -a CORE_PACKAGES=("stow" "zsh" "tmux" "git" "neovim" "ripgrep" "fzf" "gcc" "nodejs" "npm")
declare -a CORE_PACKAGES_ARCH=("fd" "eza")
declare -a CORE_PACKAGES_DEBIAN=("fd-find")
declare -a CORE_PACKAGES_FEDORA=("fd-find" "eza")

# Desktop-only packages
declare -a DESKTOP_PACKAGES=("nsxiv" "alacritty" "i3status-rust" "xdg-desktop-portal-gnome")

# ── Detect and install ────────────────────────────────────────────────
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
#          ╭──────────────────────────────────────────────────────────╮
#          │                          DEBIAN                          │
#          ╰──────────────────────────────────────────────────────────╯
    if command -v apt &> /dev/null; then
        echo "Detected Debian/Ubuntu-based system"
        sudo apt update
        
        # Install core packages
        sudo apt install -y "${CORE_PACKAGES[@]}" "${CORE_PACKAGES_DEBIAN[@]}"
        
        # Install desktop packages if needed
        if [ "$IS_DESKTOP" = true ]; then
            echo "Installing desktop packages..."
            for pkg in "${DESKTOP_PACKAGES[@]}"; do
                if apt-cache show "$pkg" &> /dev/null; then
                    sudo apt install -y "$pkg" || echo "Warning: Failed to install $pkg"
                else
                    echo "Package $pkg not available, skipping..."
                fi
            done
        fi
        
        # ── Install eza from binary (not in standard Debian repos) ────────────
        if ! command -v eza &> /dev/null; then
            echo "Installing eza from binary..."
            sudo apt install -y cargo
            git clone https://github.com/eza-community/eza.git
            cd eza
            cargo install --path .
            cd ..
            rm -rf eza
        fi
        #
#          ╭──────────────────────────────────────────────────────────╮
#          │                           ARCH                           │
#          ╰──────────────────────────────────────────────────────────╯
    elif command -v pacman &> /dev/null; then
        echo "Detected Arch-based system"
        PACKAGES=("${CORE_PACKAGES[@]}" "${CORE_PACKAGES_ARCH[@]}")
        if [ "$IS_DESKTOP" = true ]; then
            PACKAGES+=("${DESKTOP_PACKAGES[@]}")
        fi
        sudo pacman -Sy --noconfirm "${PACKAGES[@]}"

#          ╭──────────────────────────────────────────────────────────╮
#          │                          FEDORA                          │
#          ╰──────────────────────────────────────────────────────────╯
    elif command -v dnf &> /dev/null; then
        echo "Detected Fedora-based system"
        PACKAGES=("${CORE_PACKAGES[@]}" "${CORE_PACKAGES_FEDORA[@]}")
        if [ "$IS_DESKTOP" = true ]; then
            PACKAGES+=("${DESKTOP_PACKAGES[@]}")
        fi
        sudo dnf install -y "${PACKAGES[@]}"
        
    else
        echo "Unsupported package manager. Please install manually."
        exit 1
    fi
else 
    echo "Non-Linux OS I can't help you..."
    exit 1
fi

# ── install oh-my-zsh ─────────────────────────────────────────────────
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing oh-my-zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended   
    echo "Oh-my-zsh installed."
else
    echo "Oh-my-zsh already installed, skipping install."
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

if [ "$IS_DESKTOP" = true ]; then
    declare -a NERD_FONTS=("GeistMono")
    mkdir -p ~/.local/share/fonts

    # ── Download and install each font ────────────────────────────────────
    for font in "${NERD_FONTS[@]}"; do
        if ! ls "$HOME/.local/share/fonts/${font}NerdFont"*.otf 1> /dev/null 2>&1; then
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
        else
            echo "$font Nerd Font already installed."
        fi
    done

    # ── Refresh font cache ────────────────────────────────────────────────
    fc-cache -fv

    echo "Nerd fonts installed and font cache updated."
else
    echo "Skipping Nerd Fonts installation (server mode)."
fi

source "$HOME/.bashrc"
source "$HOME/.zshrc"
echo "=== Setup complete! ==="

