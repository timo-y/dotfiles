# dotfiles 
My dotfile repo.

## Requirements

### Linux
None, just clone the repo into `~` and run the `setup.sh` script. 

The script will:
- Detect your distro (Arch/Debian/Fedora) and install dependencies
- Install Oh-My-Zsh
- Use GNU Stow to symlink dotfiles
- Clone Neovim config from https://github.com/timo-y/nvim.git
- Install GeistMono Nerd Font

#### Installed Packages
Core: "stow" "zsh" "tmux" "git" "neovim" "nsxiv" "alacritty" "ripgrep" "fzf" "lazygit" "gcc" "nodejs" "npm" "uv" "eza" "i3status-rust" "xdg-desktop-portal-gnome"
Distro-specific: `fd` (Arch) or `fd-find` (Debian/Fedora)

#### Usage
```bash
git clone https://github.com/timo-y/dotfiles.git ~/dotfiles
cd ~/dotfiles
chmod +x setup.sh
./setup.sh
```

After completion, restart your shell or run `source ~/.zshrc`.

### Devpod

On the local machine:
- [docker](https://www.docker.com/products/docker-desktop/)
- [devpod](https://devpod.sh/)

need to be installed.

Additionally the projects `.devcontainer.json` needs to contain the following part in order to add _nix_ as a feature:
```json
"features": {
         "ghcr.io/devcontainers/features/nix:1": {}
     },
```

#### Usage
In the console `cd` into your project-dir (containing the `.devcontainer`-dir or the `.devcontainer.json`) and run:
```bash
devpod up . --provider docker --dotfiles https://github.com/timo-y/dotfiles.git
```
