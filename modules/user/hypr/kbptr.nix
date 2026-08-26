{
  config,
  lib,
  pkgs,
  ...
}:

let
  # High-contrast overlay palette, kept apart from the design.nix accents on purpose
  label = "#ffe600ff"; # yellow
  labelTyped = "#ff7a00ff"; # orange
  dim = "#000000aa"; # everything not selectable, darkened hard
  fill = "#0a1830e0"; # solid dark tile so the label pops
  border = "#00e5ffff"; # cyan

  # Colemak-DH, ordered by travel and alternating hands so multi-character labels do too
  labelSymbols = "tnseriaogmplfuwyqbkdhcxzvj";

  labelStyle = {
    label_font_family = "SpaceMono Nerd Font";
    label_symbols = labelSymbols;
    label_color = label;
    label_select_color = labelTyped;
  };

  # mode_tile and mode_floating share their whole surface vocabulary
  areaStyle = {
    unselectable_bg_color = dim;
    selectable_bg_color = fill;
    selectable_border_color = border;
  };

  configFile = "${config.xdg.configHome}/wl-kbptr/config";

  # wl-kbptr only autoloads $XDG_CONFIG_HOME/wl-kbptr/config, and uwsm does not
  # export XDG_CONFIG_HOME — hence the explicit -c.
  # The lockfile is to avoid multiple instances of wl-kbptr fighting over the same
  hypr-kbptr = pkgs.writeShellApplication {
    name = "hypr-kbptr";
    runtimeInputs = with pkgs; [
      wl-kbptr
      util-linux # flock
    ];
    text = ''
      lock="''${XDG_RUNTIME_DIR:-/tmp}/hypr-kbptr.lock"

      case "''${1-detect}" in
        detect) set -- ;;                    # config file defaults
        grid)   set -- -o modes=tile,click ;;
        *)      echo "usage: hypr-kbptr [detect|grid]" >&2; exit 2 ;;
      esac

      exec flock -n "$lock" wl-kbptr -c "${configFile}" "$@"
    '';
  };

  toKbptrINI = lib.generators.toINI {
    mkKeyValue = lib.generators.mkKeyValueDefault { } "=";
  };
in
{
  home.packages = [ hypr-kbptr ];

  xdg.configFile."wl-kbptr/config".text = toKbptrINI {
    general = {
      modes = "floating,click";
    };

    mode_floating =
      labelStyle
      // areaStyle
      // {
        source = "detect";
        label_font_size = "12 50% 100";
      };

    mode_tile =
      labelStyle
      // areaStyle
      // {
        label_font_size = "8 50% 100";
      };

    mode_click = {
      button = "left";
    };
  };
}
