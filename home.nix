{ pkgs, ... }:

{
  imports = [
    modules/user/video-production.nix
    modules/user/git.nix
    modules/user/nvim.nix
    modules/user/ai.nix
    modules/user/hypr
    modules/user/cursor.nix
    modules/user/terminal.nix
    modules/user/firefox.nix
    modules/user/quickshell
  ];

  gtk = {
    enable = true;
    font = {
      name = "SpaceMono Nerd Font";
      size = 11;
    };
  };

  home.packages = with pkgs; [
    vesktop
    plex-desktop
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
  programs.home-manager.enable = true; # Home manager manage itself
}
