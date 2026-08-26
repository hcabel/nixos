{ ... }:
{
  wayland.windowManager.hyprland.settings.layer_rule = [
    {
      match.namespace = "^(selection)$";
      no_anim = true; # anim ruins the experience of wl-kbptr
    }
  ];
}
