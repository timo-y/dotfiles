{
  myPackages = pkgs: pkgs.buildEnv {
    name = "timo-tools";
    paths = [
      pkgs.neovim
      pkgs.nodejs_22
      pkgs.fd
      pkgs.ripgrep
      pkgs.fzf
      pkgs.lazygit
    ];
  };
}
