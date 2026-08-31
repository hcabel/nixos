{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (import ./lib.nix lib) on;

  # The second argument to hl.exec_cmd is a one-shot window rule bound to the
  # spawned process only: Hyprland matches it via an env token the process tree
  # inherits, applies it to the first window that process maps, then drops it.
  # So this places the window launched here without pinning the app forever —
  # SUPER+Return still opens a terminal on the current workspace.
  # "silent" puts the window on the workspace without switching the view to it.
  firefox = "${config.programs.firefox.finalPackage}/bin/firefox";
  terminal = "${pkgs.kitty}/bin/kitty";
  discord = "${pkgs.vesktop}/bin/vesktop";
in
{
  wayland.windowManager.hyprland.settings.on = [
    (on "hyprland.start" ''
      hl.exec_cmd("${firefox}", { workspace = "4 silent" })
      hl.exec_cmd("${terminal}", { workspace = "6 silent" })
      hl.exec_cmd("${discord}", { workspace = "7 silent" })
    '')
  ];
}
