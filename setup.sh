#!/bin/bash

set -e  # Exit on error

echo "=== Dotfiles Setup Script ==="

# Check if Nix is installed
if ! command -v nix-env &> /dev/null; then
    echo "Nix is not installed. Installing Nix..."
    
    # Install Nix (works on Linux and macOS)
    if curl -L https://nixos.org/nix/install | sh -s -- --daemon; then
        echo "Nix installed successfully."
        
        # Source nix for the current shell session
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

# Set up XDG_CONFIG_HOME
export XDG_CONFIG_HOME="$HOME"/.config
mkdir -p "$XDG_CONFIG_HOME"
mkdir -p "$XDG_CONFIG_HOME"/nixpkgs

# Check if stow is installed, if not install it via Nix
if ! command -v stow &> /dev/null; then
    echo "GNU Stow is not installed. Installing via Nix..."
    nix-env -iA nixpkgs.stow
fi

# Run stow to create symlinks (this will place config.nix in the right location)
echo "Running GNU Stow to create symlinks..."
stow -v --adopt .

# Clone nvim config
if [ ! -d "$XDG_CONFIG_HOME/nvim" ]; then
    echo "Cloning nvim config from repo..."
    git clone https://github.com/timo-y/nvim.git "$XDG_CONFIG_HOME"/nvim
    echo "Nvim config cloned."
else
    echo "Nvim config already exists, skipping clone."
fi

# Install dependencies via Nix
echo "Installing packages via Nix..."
nix-channel --add https://nixos.org/channels/nixpkgs-unstable nixpkgs
nix-channel --update

# Install `myPackages` defined in config.nix (now stowed to ~/.config/nixpkgs/config.nix)
nix-env -iA nixpkgs.myPackages

echo "All Nix packages have been installed."

echo "=== Setup complete! ==="
echo "Please restart your shell or run 'source ~/.bashrc' or 'source ~/.zshrc'".

