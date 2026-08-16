{ lib, ... }:

let
  inherit (lib) mkOption types;

  s =
    default:
    mkOption {
      type = types.str;
      inherit default;
    };
in
{
  options.hcabel.style = {
    font.mono = s "CaskaydiaMono Nerd Font";

    palette = {
      base = s "#05070a";
      surface = s "#18162c";
      overlay = s "#241f38";
      muted = s "#565a7a";
      text = s "#ffffff";

      accent = s "#7aa2f7"; # the blue that starts every gradient
      accentMid = s "#a78bfa"; # the purple in the middle
      accentAlt = s "#f28fad"; # the pink that ends it

      border = s "#7aa2f7";
      borderInactive = s "#1e1b33";

      red = s "#f7768e";
    };
  };
}
