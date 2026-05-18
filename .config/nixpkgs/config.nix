{
  packageOverrides = pkgs: with pkgs; {
    timosCorePackages = pkgs.buildEnv {
      name = "timos-core-tools";
      paths = [
        stow
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
        # ── yazi + preview deps ─────────────────────────────────
        yazi              # tui file manager
        poppler_utils     # pdftoppm: pdf preview
        ffmpegthumbnailer # video thumbs
        imagemagick       # broad image formats (heic, etc.)
        chafa             # terminal image preview fallback
        _7zz              # 7zz: archive preview/extract
        jq                # json preview
        zoxide            # yazi `z` jump integration
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
        nerd-fonts.geist-mono
      ];
    };
  };
}
