{ pkgs, ... }:

{
  imports = [
    ../modules/home/style.nix
    ../modules/home/hyprland
    ../modules/home/quickshell
    ../modules/home/kbptr.nix
    ../modules/home/ai.nix
    # ../modules/home/shell.nix
    ../modules/home/terminal.nix
    ../modules/home/git.nix
    ../modules/home/firefox.nix
    # ../modules/home/yazi.nix
    ../modules/home/nvim.nix
    # ../modules/home/lock.nix
  ];

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "26.05";

  # xdg.enable = true;
  # xdg.userDirs = {
  #     enable = true;
  #     createDirectories = true;
  # };

  gtk = {
    enable = true;
    theme = {
      name = "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;
    gtk4.extraConfig.gtk-application-prefer-dark-theme = 1;
  };
  qt = {
    enable = true;
    platformTheme.name = "gtk3";
  };

  home.pointerCursor = {
    enable = true;
    name = "Bibata-Modern-Ice";
    package = pkgs.bibata-cursors;
    size = 24;
    gtk.enable = true;
    hyprcursor.enable = true;
  };

  programs.home-manager.enable = true;
}
