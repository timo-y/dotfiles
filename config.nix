{
  packageOverrides = pkgs: with pkgs; {
    myPackages = pkgs.buildEnv {
      name = "timo-tools";
      paths = [
        neovim
        zsh
        nodejs_22
        fd
        ripgrep
        fzf
        lazygit
        git
        oh-my-zsh
      ];
    };
  };
};
