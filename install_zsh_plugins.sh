#!/bin/bash

set -e  # Exit on error

echo "Installing Zsh plugins..."

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# Check if Oh My Zsh is installed
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Oh My Zsh is not installed. Please install it first."
    exit 1
fi

# ── zsh-autosuggestions ───────────────────────────────────────────────
PLUGIN_DIR="$ZSH_CUSTOM/plugins/zsh-autosuggestions"
if [ ! -d "$PLUGIN_DIR" ]; then
    echo "Installing zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "$PLUGIN_DIR"
else
    echo "zsh-autosuggestions already installed, skipping."
fi

# ── zsh-syntax-highlighting ───────────────────────────────────────────
PLUGIN_DIR="$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
if [ ! -d "$PLUGIN_DIR" ]; then
    echo "Installing zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting "$PLUGIN_DIR"
else
    echo "zsh-syntax-highlighting already installed, skipping."
fi

echo "Zsh plugins installed successfully!"
