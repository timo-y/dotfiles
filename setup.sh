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
#                                                            ▲
#   Desktop-only packages, that are installed by the native  █
#   package manager because they need hardware access        █
#                                                            ▼
declare -a DESKTOP_PACKAGES=("alacritty")

if [ "$IS_DESKTOP" = true ]; then
    echo "Installing desktop packages..."
    # ── Detect and install ────────────────────────────────────────────────
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        #          ╭──────────────────────────────────────────────────────────╮
        #          │                          DEBIAN                          │
        #          ╰──────────────────────────────────────────────────────────╯
        if command -v apt &> /dev/null; then
            echo "Detected Debian/Ubuntu-based system"
            sudo apt update
            sudo api install -y "${DESKTOP_PACKAGES[@]}"
            
        #          ╭──────────────────────────────────────────────────────────╮
        #          │                           ARCH                           │
        #          ╰──────────────────────────────────────────────────────────╯
        elif command -v pacman &> /dev/null; then
            echo "Detected Arch-based system"
            sudo pacman -Sy --noconfirm "${DESKTOP_PACKAGES[@]}"

        #          ╭──────────────────────────────────────────────────────────╮
        #          │                          FEDORA                          │
        #          ╰──────────────────────────────────────────────────────────╯
        elif command -v dnf &> /dev/null; then
            echo "Detected Fedora-based system"
            sudo dnf install -y "${DESKTOP_PACKAGES[@]}"
        else
            echo "Unsupported package manager. Please install manually."
            exit 1
        fi
    else 
        echo "Non-Linux OS I can't help you..."
        exit 1
    fi
    echo "All packages installed."
else
    echo "Skipping desktop packages installation with native package manager (server mode)."
fi

#          ╭──────────────────────────────────────────────────────────╮
#          │                           Nix                            │
#          ╰──────────────────────────────────────────────────────────╯
if ! command -v nix-env &> /dev/null; then
    echo "Nix is not installed. Installing Nix..."
    
    # ── Install Nix (works on Linux and macOS) ────────────────────────────
    if curl -L https://nixos.org/nix/install | sh -s -- --daemon; then
        echo "Nix installed successfully."
        
        # ── Source nix for the current shell session ──────────────────────────
        if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
            . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
        fi
    else
        echo "Failed to install Nix. Please install manually from https://nixos.org/download.html"
        exit 1
    fi
else
    echo "Nix is already installed."
fi

# ── Install dependencies via Nix ──────────────────────────────────────
echo "Installing packages via Nix..."
nix-channel --add https://nixos.org/channels/nixpkgs-unstable nixpkgs
nix-channel --update

# Install the packages defined in config.nix (now stowed to ~/.config/nixpkgs/config.nix)
echo "Installing core packages..."
nix-env -iA nixpkgs.corePackages
echo "Core packages installed."
if [ "$IS_DESKTOP" = true ]; then
    echo "Installing desktop packages..."
    nix-env -iA nixpkgs.desktopPackages
    echo "Desktop packages installed."
else
    echo "Skipping desktop packages installation (server mode)."
fi
echo "All packages installed."

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

source "$HOME/.bashrc"
source "$HOME/.zshrc"
echo "=== Setup complete! ==="

