{ config, pkgs, ... }:

let
  style = config.hcabel.style;
  p = style.palette;

  # wl-kbptr wants #rrggbbaa. Only pass opaque "#rrggbb" tokens through here —
  # the alpha rungs (ink, tint, hairline) are already ARGB and would come out
  # ten digits long.
  a = col: alphaHex: "${col}${alphaHex}";

  # Deliberately garish, and deliberately NOT brand: these have to be findable
  # in a fraction of a second against arbitrary screen content.
  label = "#ffe600";
  labelHighlight = "#ff7a00";
in
{
  home.packages = [ pkgs.wl-kbptr ];

  xdg.configFile."wl-kbptr/config".text = ''
    # Managed by home-manager — see modules/home/kbptr.nix

    [general]
    home_row_keys=
    cancellation_status_code=0

    [mode_tile]
    label_color=${a label "ff"}
    label_select_color=${a labelHighlight "ff"}
    unselectable_bg_color=${a p.bg.inset "ab"}
    selectable_bg_color=${a p.bg.surface "e0"}
    selectable_border_color=${a p.accent.secondary.fill "ff"}
    label_font_family=${style.font.mono}
    label_font_size=8 50% 100
    label_symbols=abcdefghijklmnorstuvwxyz

    [mode_floating]
    source=detect
    label_color=${a label "ff"}
    label_select_color=${a labelHighlight "ff"}
    unselectable_bg_color=${a p.bg.inset "ab"}
    selectable_bg_color=${a p.bg.surface "e0"}
    selectable_border_color=${a p.accent.secondary.fill "ff"}
    label_font_family=${style.font.mono}
    label_font_size=12 50% 100
    label_symbols=abcdefghijklmnorstuvwxyz

    [mode_bisect]
    label_color=${a label "ff"}
    label_font_size=20
    label_font_family=${style.font.mono}
    label_padding=12
    pointer_size=20
    pointer_color=${a p.status.critical "ff"}
    unselectable_bg_color=${a p.bg.inset "ab"}
    even_area_bg_color=${a p.bg.surface "bf"}
    even_area_border_color=${a p.accent.secondary.fill "ff"}
    odd_area_bg_color=${a p.bg.raised "80"}
    odd_area_border_color=${a labelHighlight "ff"}
    history_border_color=${a p.text.secondary "ff"}

    [mode_split]
    pointer_size=20
    pointer_color=${a p.status.critical "ff"}
    bg_color=${a p.bg.inset "ab"}
    area_bg_color=${a p.bg.surface "bf"}
    vertical_color=${a p.accent.secondary.fill "ff"}
    horizontal_color=${a p.accent.structural.fill "ff"}
    history_border_color=${a p.text.secondary "ff"}

    [mode_click]
    button=left
  '';
}
