{ config, pkgs, ... }:

let
  style = config.hcabel.style;
  p = style.palette;

  # wl-kbptr wants #rrggbbaa.
  a = col: alphaHex: "${col}${alphaHex}";

  # Very contrasted colors for ease of use
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
    unselectable_bg_color=${a p.base "ab"}
    selectable_bg_color=${a p.surface "e0"}
    selectable_border_color=${a p.border "ff"}
    label_font_family=${style.font.mono}
    label_font_size=8 50% 100
    label_symbols=abcdefghijklmnorstuvwxyz

    [mode_floating]
    source=detect
    label_color=${a label "ff"}
    label_select_color=${a labelHighlight "ff"}
    unselectable_bg_color=${a p.base "ab"}
    selectable_bg_color=${a p.surface "e0"}
    selectable_border_color=${a p.border "ff"}
    label_font_family=${style.font.mono}
    label_font_size=12 50% 100
    label_symbols=abcdefghijklmnorstuvwxyz

    [mode_bisect]
    label_color=${a label "ff"}
    label_font_size=20
    label_font_family=${style.font.mono}
    label_padding=12
    pointer_size=20
    pointer_color=${a p.red "ff"}
    unselectable_bg_color=${a p.base "ab"}
    even_area_bg_color=${a p.surface "bf"}
    even_area_border_color=${a p.border "ff"}
    odd_area_bg_color=${a p.overlay "80"}
    odd_area_border_color=${a labelHighlight "ff"}
    history_border_color=${a p.muted "ff"}

    [mode_split]
    pointer_size=20
    pointer_color=${a p.red "ff"}
    bg_color=${a p.base "ab"}
    area_bg_color=${a p.surface "bf"}
    vertical_color=${a p.border "ff"}
    horizontal_color=${a p.accentAlt "ff"}
    history_border_color=${a p.muted "ff"}

    [mode_click]
    button=left
  '';
}
