{ pkgs, ... }:

let
  env = name: value: {
    _args = [
      name
      value
    ];
  };
in
{
  imports = [
    ./binds.nix
    ./design.nix
  ];

  home.packages = with pkgs; [
    kitty
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    # set the Hyprland and XDPH packages to null to use the ones from the NixOS module
    package = null;
    portalPackage = null;
    systemd.enable = false; # uwsm manages the session

    settings = {
      gesture = {
        fingers = 3;
        direction = "horizontal";
        action = "workspace";
      };

      monitor = {
        output = "";
        mode = "preferred";
        position = "auto";
        scale = "1";
      };

      config = {
        input = {
          touchpad = {
            natural_scroll = true;
          };
        };

        misc = {
          disable_hyprland_logo = true;
          disable_splash_rendering = true;
          vrr = 2;
          mouse_move_enables_dpms = true;
          focus_on_activate = false;
          initial_workspace_tracking = 0;
          middle_click_paste = false;
          enable_anr_dialog = true;
          anr_missed_pings = 15;
          allow_session_lock_restore = true;
        };

        dwindle = {
          preserve_split = true;
          special_scale_factor = 0.8;
        };

        ecosystem = {
          no_update_news = true;
          no_donation_nag = true;
        };
      };

      env = [
        # Drive the session off the iGPU — the laptop panel and HDMI are both
        # wired to it, and this lets the 4060 stay asleep. /dev/dri/igpu is a
        # symlink from modules/sys/nvidia.nix; the by-path one can't be used
        # here because aquamarine splits this value on ":".
        (env "AQ_DRM_DEVICES" "/dev/dri/igpu")
        (env "NIXOS_OZONE_WL" "1")
      ];
    };
  };
}
