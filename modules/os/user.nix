{ pkgs, ... }:

{
  programs.fish.enable = true;

  users.users.hcabel = {
    isNormalUser = true;
    group = "hcabel";
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
      "input"
    ];
    shell = pkgs.fish;
  };
  users.groups.hcabel = { };
}
