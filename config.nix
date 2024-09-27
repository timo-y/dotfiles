{
  packageOverrides = pkgs: with pkgs; {
    myPackages = pkgs.buildEnv {
      name = "timo-tools";
      paths = [
        neovim
        nodejs_22
        fd
        ripgrep
        fzf
        lazygit
      ];
    };
  };
}
