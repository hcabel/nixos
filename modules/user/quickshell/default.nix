{ config, ... }:

{
  programs.quickshell = {
    enable = true;
    activeConfig = "hcabel";
    systemd.enable = true;
  };

  # Use symlink for hot reload
  xdg.configFile."quickshell/hcabel".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos/modules/user/quickshell/qs";
}
