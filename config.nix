{
  packageOverrides = pkgs: with pkgs; {
    myPackages = pkgs.buildEnv {
      name = "timo-tools";
      paths = [
        gcc
        neovim
        zsh
        oh-my-zsh
        nodejs_22
        fd
        ripgrep
        fzf
        git
        lazygit
      ];
    };
  };
}
