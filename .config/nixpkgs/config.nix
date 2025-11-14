{
  packageOverrides = pkgs: with pkgs; {
    myPackages = pkgs.buildEnv {
      name = "timo-tools";
      paths = [
        zsh
        oh-my-zsh
        neovim
        alacritty
        nodejs_22 
        gcc
        fd # find
        ripgrep # grep
        fzf # fuzzy finder
        git
        lazygit # git gui
      ];
    };
  };
}
