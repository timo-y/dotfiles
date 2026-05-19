#!/bin/bash

set -e  # Exit on error

# ── Detect if we need sudo ───────────────────────────────────────────
if [ "$EUID" -eq 0 ] || [ ! -x "$(command -v sudo)" ]; then
    SUDO=""
    echo "Running as root or sudo not available - commands will run directly"
else
    SUDO="sudo"
    echo "Running with sudo privileges"
fi

echo "=== Dotfiles + Dependencies Setup Script ==="

# ── Parse command line arguments ──────────────────────────────────────
IS_DESKTOP=false
MODE_SPECIFIED=false
HOST_NAME="$(uname -n)"

while [[ $# -gt 0 ]]; do
    case $1 in
        --server-install)
            IS_DESKTOP=false
            MODE_SPECIFIED=true
            echo "Server/headless installation mode selected."
            shift
            ;;
        --desktop-install)
            IS_DESKTOP=true
            MODE_SPECIFIED=true
            echo "Desktop installation mode selected."
            shift
            ;;
        --host)
            HOST_NAME="$2"
            shift 2
            ;;
        --host=*)
            HOST_NAME="${1#*=}"
            shift
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [--server-install|--desktop-install] [--host NAME]"
            exit 1
            ;;
    esac
done

echo "Host overlay: $HOST_NAME (looked up in ./hosts/$HOST_NAME)"

# ── Ask installation type if not specified ───────────────────────────
# Devcontainer/devpod sets $DEVCONTAINER=true (see .devcontainer/Dockerfile).
# Skip the prompt and force server mode when running inside a container.
if [[ "$MODE_SPECIFIED" == false && "$DEVCONTAINER" == "true" ]]; then
    IS_DESKTOP=false
    MODE_SPECIFIED=true
    echo "Devcontainer detected (\$DEVCONTAINER=true) — defaulting to server/headless mode."
fi

if [[ "$MODE_SPECIFIED" == false ]]; then
    read -p "Is this a desktop installation? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        IS_DESKTOP=true
        echo "Setting up for desktop environment..."
    else
        IS_DESKTOP=false
        echo "Setting up for server/headless environment..."
    fi
elif [[ "$IS_DESKTOP" == true ]]; then
    echo "Setting up for desktop environment..."
else
    echo "Setting up for server/headless environment..."
fi

TOTAL_STEPS=4
I=0
#          ╭──────────────────────────────────────────────────────────╮
#          │                       Dependencies                       │
#          ╰──────────────────────────────────────────────────────────╯
#                                                            ▲
#   Packages, that are installed by the native               █
#   package manager because they need hardware access        █
#                                                            ▼
declare -a CORE_PACKAGES=("git" "stow" "zsh")
declare -a CORE_PACKAGES_ARCH=("xz")
declare -a CORE_PACKAGES_DEBIAN=("xz-utils")
declare -a CORE_PACKAGES_FEDORA=("xz")
declare -a DESKTOP_PACKAGES=("alacritty")

((I=I+1))
echo "[Step $I/$TOTAL_STEPS] Installing packages via native package manager..."
# ── Detect and install ────────────────────────────────────────────────
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # ── DEBIAN ────────────────────────────────────────────────────────────
    if command -v apt &> /dev/null; then
        echo "Detected Debian/Ubuntu-based system"
        PACKAGES=("${CORE_PACKAGES[@]}" "${CORE_PACKAGES_DEBIAN[@]}")
        $SUDO apt update
        if $IS_DESKTOP; then
            PACKAGES+=("${DESKTOP_PACKAGES[@]}")
        fi
        $SUDO apt install -y "${PACKAGES[@]}"

    # ── ARCH ──────────────────────────────────────────────────────────────
    elif command -v pacman &> /dev/null; then
        echo "Detected Arch-based system"
        PACKAGES=("${CORE_PACKAGES[@]}" "${CORE_PACKAGES_ARCH[@]}")
        if $IS_DESKTOP; then
            PACKAGES+=("${DESKTOP_PACKAGES[@]}")
        fi
        $SUDO pacman -Sy --noconfirm "${PACKAGES[@]}"

    # ── FEDORA ────────────────────────────────────────────────────────────
    elif command -v dnf &> /dev/null; then
        echo "Detected Fedora-based system"
        PACKAGES=("${CORE_PACKAGES[@]}" "${CORE_PACKAGES_FEDORA[@]}")
        if $IS_DESKTOP; then
            PACKAGES+=("${DESKTOP_PACKAGES[@]}")
        fi
        $SUDO dnf install -y "${PACKAGES[@]}"

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
((I=I+1))
echo "[Step $I/$TOTAL_STEPS] Setting up dotfiles..."

# ── Set up XDG_CONFIG_HOME ────────────────────────────────────────────
export XDG_CONFIG_HOME="$HOME"/.config
mkdir -p "$XDG_CONFIG_HOME"

# ── dotfiles ──────────────────────────────────────────────────────────
echo "Running GNU Stow to create symlinks (base package)..."
stow -v --adopt .
echo "Base dotfiles installed."

# ── Host overlay ──────────────────────────────────────────────────────
# Each hosts/<name>/ is a separate stow package layered on top of the base.
# Used for machine-specific config (e.g. monitor/display layouts).
# Base configs (i3, hyprland) include from host.d/*.conf so missing overlay
# is a no-op — safe for any machine without a matching hosts/<name>/ dir.
if [ -d "hosts/$HOST_NAME" ]; then
    echo "Stowing host overlay: hosts/$HOST_NAME"
    stow -v --adopt --no-folding -d hosts -t "$HOME" "$HOST_NAME"
    echo "Host overlay installed."
else
    echo "No hosts/$HOST_NAME directory — skipping host overlay (this is fine for new machines)."
fi

# ── nvim ──────────────────────────────────────────────────────────────
if [ ! -d "$XDG_CONFIG_HOME/nvim" ]; then
    echo "Cloning nvim config from repo..."
    git clone https://github.com/timo-y/nvim.git "$XDG_CONFIG_HOME"/nvim
    echo "Nvim config cloned."
else
    echo "Nvim config already exists, skipping clone."
fi

#          ╭──────────────────────────────────────────────────────────╮
#          │                           Nix                            │
#          ╰──────────────────────────────────────────────────────────╯
((I=I+1))
echo "[Step $I/$TOTAL_STEPS] Installing Nix and Nix packages..."
if ! command -v nix-env &> /dev/null; then
    echo "Nix is not installed. Installing Nix..."
    
    # ── Install Nix (works on Linux and macOS) ────────────────────────────
    if curl -L https://nixos.org/nix/install | sh -s -- --no-daemon; then
        echo "Nix installed successfully."

        # ── Source nix for the current shell session ──────────────────────────
    	. "$HOME/.nix-profile/etc/profile.d/nix.sh"
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
nix-env -iA nixpkgs.timosCorePackages
echo "Core packages installed."
if $IS_DESKTOP; then
    echo "Installing desktop packages..."
    nix-env -iA nixpkgs.timosDesktopPackages
    echo "Desktop packages installed."
else
    echo "Skipping desktop packages installation (server mode)."
fi

#          ╭──────────────────────────────────────────────────────────╮
#          │        Post-Dependency-Installation Configuration        │
#          ╰──────────────────────────────────────────────────────────╯
((I=I+1))
echo "[Step $I/$TOTAL_STEPS] Installing zsh and plugins..."
# Install oh-my-zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "oh-my-zsh is not installed. Installing oh-my-zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    echo "oh-my-zsh installed successfully."
else
    echo "oh-my-zsh is already installed."
fi
# ── Install zsh plugins ───────────────────────────────────────────────
sh ./install_zsh_plugins.sh

echo "All packages installed."

echo "=== Setup complete! ==="
echo "You need to run 'source ~/.bashrc' and 'source ~/.zshrc' or restart your shell for the changes to take effect."
