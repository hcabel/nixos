{ ... }:
{
  wayland.windowManager.hyprland.settings.layer_rule = [
    {
      match.namespace = "^(selection)$";
      no_anim = true; # anim ruins the experience of wl-kbptr
    }

    {
      match.namespace = "^(quickshell:.*)$";
      no_anim = true;
    }
    {
      match.namespace = "^(quickshell:frame)$";
      blur = true;

      ignore_alpha = 0.1; # Should not be 0 or the blur will affect the QS viewport
    }
    {
      match.namespace = "^(quickshell:toasts)$";
      blur = true;

      ignore_alpha = 0.1;
    }
  ];
}
