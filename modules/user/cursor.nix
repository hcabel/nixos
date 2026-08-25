{ pkgs, ... }:

let
  env = name: value: {
    _args = [
      name
      value
    ];
  };
  hyprcursorTheme = "rose-pine-hyprcursor";
  xcursorTheme = "BreezeX-RosePine-Linux";
  cursorSize = 24;
in
{
  home.pointerCursor = {
    package = pkgs.rose-pine-cursor;
    name = xcursorTheme;
    size = cursorSize;

    gtk.enable = true;
    x11.enable = true;
    # hyprcursor.enable stays off on purpose — see below
  };

  # Put the hyprcursor theme somewhere both cursor libraries actually look.
  home.file.".local/share/icons/${hyprcursorTheme}".source =
    "${pkgs.rose-pine-hyprcursor}/share/icons/${hyprcursorTheme}";

  wayland.windowManager.hyprland.settings.env = [
    (env "HYPRCURSOR_THEME" hyprcursorTheme)
    (env "HYPRCURSOR_SIZE" (toString cursorSize))
    (env "XCURSOR_THEME" xcursorTheme)
    (env "XCURSOR_SIZE" (toString cursorSize))
  ];
}
