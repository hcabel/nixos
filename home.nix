{ ... }:

{
  imports = [
    modules/user/video-production.nix
    modules/user/git.nix
    modules/user/nvim.nix
    modules/user/ai.nix
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
