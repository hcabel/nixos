{ pkgs, ... }:

{
  programs.fish.enable = true;
  users.users."hcabel" = {
    isNormalUser = true;
    description = "hcabel";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    shell = pkgs.fish;
  };
}
