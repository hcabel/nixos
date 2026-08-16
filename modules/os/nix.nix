{ ... }:
{
  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      trusted-users = [
        "root"
        "hcabel"
      ];
      auto-optimise-store = true;

      substituters = [
        "https://cache.nixos.org"
        "https://hyprland.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      ];
    };
  };

  programs.nh = {
    enable = true;
    flake = "/home/hcabel/nixos/";
    clean = {
      enable = true;
      extraArgs = "--keep-since 21d --keep 5";
    };
  };

  nixpkgs.config.allowUnfree = true;
}
