{ lib, ... }:

let
  inherit (lib) mkOption types;

  s =
    default:
    mkOption {
      type = types.str;
      inherit default;
    };

  i =
    default:
    mkOption {
      type = types.int;
      inherit default;
    };

  f =
    default:
    mkOption {
      type = types.float;
      inherit default;
    };
in
{
  options.hcabel.style = {
    font = {
      mono = s "CaskaydiaMono Nerd Font";
      size = i 13;
    };

    frameOpacity = f 0.80;

    sizes = {
      barHeight = i 40;
      rail = i 10;
      rounding = i 14;
      padding = i 8;
      gap = i 6;

      drawerRounding = i 18;
      fillet = i 14;
      panelWidth = i 360;
      drawerDuration = i 350;
      animFast = i 150;

      shadowRange = i 32;
      shadowBands = i 24;
    };

    opacity = {
      shadow = f 0.55;
      hairline = f 0.10;

      chromeFill = f 0.055;
      chromeFillStrong = f 0.08;
      chromeBorder = f 0.07;
      chromeLabel = f 0.66;
    };

    palette = {
      base = s "#05070a";
      surface = s "#18162c";
      overlay = s "#241f38";
      muted = s "#565a7a";
      text = s "#ffffff";

      accent = s "#7aa2f7";
      accentMid = s "#a78bfa";
      accentAlt = s "#f28fad";

      border = s "#7aa2f7";
      borderInactive = s "#1e1b33";

      red = s "#f7768e";

      shadow = s "#04040c";
      accentInk = s "#0c1420"; # text laid over an accent fill
    };
  };
}
