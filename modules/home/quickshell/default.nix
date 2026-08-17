{ config, pkgs, ... }:

# Uses simlink instead of letting NixOs own it, so we can iterate more quickly without switching generations.

let
  style = config.hcabel.style;
  p = style.palette;

  qsDir = "${config.home.homeDirectory}/nixos/modules/home/quickshell/qs";

  # Flat on purpose — a nested JsonAdapter needs a nested JsonObject per level of the tree.
  styleJson = {
    inherit (p)
      base
      surface
      overlay
      muted
      text
      accent
      accentMid
      accentAlt
      border
      borderInactive
      red
      shadow
      accentInk
      ;

    inherit (style.opacity)
      chromeFill
      chromeFillStrong
      chromeBorder
      chromeLabel
      ;

    shadowOpacity = style.opacity.shadow;
    hairlineOpacity = style.opacity.hairline;

    fontMono = style.font.mono;
    fontSize = style.font.size;

    barHeight = style.sizes.barHeight;
    rail = style.sizes.rail;
    rounding = style.sizes.rounding;
    padding = style.sizes.padding;
    gap = style.sizes.gap;

    drawerRounding = style.sizes.drawerRounding;
    fillet = style.sizes.fillet;
    panelWidth = style.sizes.panelWidth;
    drawerDuration = style.sizes.drawerDuration;
    animFast = style.sizes.animFast;
    shadowRange = style.sizes.shadowRange;
    shadowBands = style.sizes.shadowBands;

    barOpacity = style.frameOpacity;
  };
in
{
  programs.quickshell = {
    enable = true;
    package = pkgs.quickshell;
    activeConfig = "hcabel";
    systemd.enable = true;
  };

  xdg.configFile."quickshell/hcabel".source = config.lib.file.mkOutOfStoreSymlink qsDir;
  xdg.configFile."quickshell/style.json".text = builtins.toJSON styleJson;
}
