{ ... }:

{
  users.users."hcabel" = {
    isNormalUser = true;
    description = "hcabel";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };
}
