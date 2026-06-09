#!/bin/bash

set -e  # Exit on error

echo "Installing tmux plugins..."

TMUX_DIR="${TMUX_DIR:-$HOME/.tmux/}"
THEMES_DIR="$TMUX_DIR/themes/"


if [ ! -d "$THEMES_DIR/srcery-tmux" ]; then
    echo "Installing srcery-tmux theme..."
    git clone https://github.com/srcery-colors/srcery-tmux/ "$TMUX_DIR/themes/srcery-tmux"
else
    echo "srcery-tmux theme already installed, skipping."
fi

echo "tmux plugins installed successfully!"

