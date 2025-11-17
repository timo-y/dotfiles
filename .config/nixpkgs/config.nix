{
  packageOverrides = pkgs: with pkgs; {
    corePackages = pkgs.buildEnv {
      name = "core-tools";
      paths = [
        stow
        zsh
        tmux
        oh-my-zsh
        neovim
        nodejs_22 
        npm
        eza # ls alias
        gcc
        fd # find
        ripgrep # grep
        fzf # fuzzy finder
        git
        lazygit # git gui
      ];
    };
    desktopPackages = pkgs.buildEnv {
      name = "desktop-tools";
      paths = [
        nsxiv
        i3status-rust
        xdg-desktop-portal-gnome
        kitty
        waybar
        nerd-fonts.geist-mono
      ];
    };
  };
}
