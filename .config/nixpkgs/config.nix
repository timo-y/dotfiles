{
  packageOverrides = pkgs: with pkgs; {
    timosCorePackages = pkgs.buildEnv {
      name = "timos-core-tools";
      paths = [
        stow
        zsh
        tmux
        oh-my-zsh
        neovim
        nodejs 
        eza # ls alias
        gcc
        fd # find
        ripgrep # grep
        fzf # fuzzy finder
        git
        lazygit # git gui
        nerd-fonts.geist-mono
      ];
    };
    timosDesktopPackages = pkgs.buildEnv {
      name = "timos-desktop-tools";
      paths = [
        nsxiv
        i3status-rust
        xdg-desktop-portal-gnome
        kitty
        waybar
      ];
    };
  };
}
