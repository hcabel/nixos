{ config, pkgs, ... }:

# Uses simlink instead of letting NixOs own it, so we can iterate more quickly without switching generations.

let
  qsDir = "${config.home.homeDirectory}/nixos/modules/home/quickshell/qs";
in
{
  programs.quickshell = {
    enable = true;
    package = pkgs.quickshell;
    activeConfig = "hcabel";
    systemd.enable = true;
  };

  xdg.configFile."quickshell/hcabel".source = config.lib.file.mkOutOfStoreSymlink qsDir;
  xdg.configFile."quickshell/style.json".text = builtins.toJSON config.hcabel.style;
}
