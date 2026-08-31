{ ... }:

let
  surface = "rgb(18162C)";
  text = "rgb(FAF3E6)";
  accent = "rgb(7AA2F7)";
  danger = "rgb(F7768E)";
in
{
  programs.hyprlock = {
    enable = true;

    settings = {
      general = {
        hide_cursor = true;
        grace = 0;
      };

      background = [
        {
          path = "screenshot";
          blur_passes = 3;
          blur_size = 8;
          brightness = 0.4;
        }
      ];

      input-field = [
        {
          size = "280, 50";
          position = "0, -40";
          halign = "center";
          valign = "center";

          outline_thickness = 2;
          rounding = 18;

          outer_color = accent;
          inner_color = surface;
          font_color = text;
          check_color = accent;
          fail_color = danger;

          font_family = "SpaceMono Nerd Font";
          placeholder_text = "";
          fade_on_empty = false;
        }
      ];

      label = [
        {
          text = "$TIME";
          position = "0, 80";
          halign = "center";
          valign = "center";

          color = text;
          font_family = "SpaceMono Nerd Font";
          font_size = 56;
        }
      ];
    };
  };
}
