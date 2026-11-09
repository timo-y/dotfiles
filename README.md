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

#### Host overlays
Machine-specific config (monitor/display layout, keyboard layouts, workspace
pinning, etc.) lives in `hosts/<hostname>/` and is stowed as a **separate**
package. The base configs contain no host-specific display or keyboard
settings: the window managers include `~/.config/<wm>/host.d/*.conf` (i3,
sway) and the Hyprland Lua config loads `host.d/display.lua` and
`host.d/keyboard.lua` if present. Missing overlays are a no-op, so a new
machine works with the base package alone. If you stow
manually, install both the base package and the overlay, and use
`--no-folding` so the overlay can merge into `~/.config`:

```bash
cd ~/dotfiles
stow -v --adopt --no-folding .
stow -v --adopt --no-folding -d hosts -t "$HOME" "$(uname -n)"
swaymsg reload
```

If `~/.config/sway` (or `i3`/`hypr`) is already a folded symlink from an older
install, remove that symlink first; otherwise stow will refuse to add
`host.d/` inside it. `setup.sh` now does this automatically.

Current overlays:
- `hosts/tptimo/`: laptop — US keyboard (German Corne), no display overrides.
- `hosts/HOME-PC/`: desktop — German keyboard and dual-monitor layout.

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
