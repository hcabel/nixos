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
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
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
