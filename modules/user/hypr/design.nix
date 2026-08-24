{ ... }:

let
  accent-primary = "f23e96";
  accent-secondary = "12d6de";
  bg-surface = "2a2d31";
  text-primary = "faf3e6";
  text-accent = "1e2023";
in
{
  wayland.windowManager.hyprland.settings = {
    config = {
      general = {
        layout = "dwindle";
        resize_on_border = true;

        gaps_in = 6;
        gaps_out = 12;

        col = {
          active_border = {
            colors = [
              "rgb(${accent-primary})"
              "rgb(${accent-secondary})"
              "rgb(e0a855)"
            ];
            angle = 45;
          };
          inactive_border = "rgb(${bg-surface})";
        };
      };

      decoration = {
        rounding = 18;

        active_opacity = 0.95;
        inactive_opacity = 0.82;
        fullscreen_opacity = 1.0;

        blur = {
          enabled = true;
          size = 12;
          passes = 4;
          noise = 0.02;
          contrast = 1.05;
          brightness = 1.0;
          vibrancy = 0.55;
          vibrancy_darkness = 0.15;
        };

        shadow = {
          enabled = true;
          range = 18;
          render_power = 3;
          offset = [
            0
            6
          ];
          color = "rgba(00000061)";
        };
      };

      group = {
        col = {
          border_active = "rgb(${accent-primary})";
          border_inactive = "rgb(${bg-surface})";
        };

        groupbar = {
          font_family = "SpaceMono Nerd Font";
          font_size = 12;
          col = {
            active = "rgb(${accent-primary})";
            inactive = "rgb(${bg-surface})";
          };
          text_color = "rgb(${text-accent})";
          text_color_inactive = "rgb(${text-primary})";
        };
      };
    };

    # ── hl.curve ─────────────────────────────────────────────────────────
    curve = [
      {
        _args = [
          "wind"
          {
            type = "bezier";
            points = [
              [
                0.05
                0.9
              ]
              [
                0.1
                1.05
              ]
            ];
          }
        ];
      }
      {
        _args = [
          "winIn"
          {
            type = "bezier";
            points = [
              [
                0.1
                1.1
              ]
              [
                0.1
                1.1
              ]
            ];
          }
        ];
      }
      {
        _args = [
          "winOut"
          {
            type = "bezier";
            points = [
              [
                0.3
                (-0.3)
              ]
              [
                0
                1
              ]
            ];
          }
        ];
      }
      {
        _args = [
          "liner"
          {
            type = "bezier";
            points = [
              [
                1
                1
              ]
              [
                1
                1
              ]
            ];
          }
        ];
      }
      {
        _args = [
          "md3_decel"
          {
            type = "bezier";
            points = [
              [
                0.05
                0.7
              ]
              [
                0.1
                1
              ]
            ];
          }
        ];
      }
      {
        _args = [
          "menu_decel"
          {
            type = "bezier";
            points = [
              [
                0.1
                1
              ]
              [
                0
                1
              ]
            ];
          }
        ];
      }
      {
        _args = [
          "menu_accel"
          {
            type = "bezier";
            points = [
              [
                0.38
                0.04
              ]
              [
                1
                0.07
              ]
            ];
          }
        ];
      }
    ];

    # ── hl.animation ─────────────────────────────────────────────────────
    animation = [
      {
        leaf = "windows";
        enabled = true;
        speed = 6.0;
        bezier = "wind";
        style = "slide";
      }
      {
        leaf = "windowsIn";
        enabled = true;
        speed = 6.0;
        bezier = "winIn";
        style = "slide";
      }
      {
        leaf = "windowsOut";
        enabled = true;
        speed = 5.0;
        bezier = "winOut";
        style = "slide";
      }
      {
        leaf = "windowsMove";
        enabled = true;
        speed = 5.0;
        bezier = "wind";
        style = "slide";
      }
      {
        leaf = "fade";
        enabled = true;
        speed = 3.0;
        bezier = "md3_decel";
      }
      {
        leaf = "layersIn";
        enabled = true;
        speed = 3.0;
        bezier = "menu_decel";
        style = "slide";
      }
      {
        leaf = "layersOut";
        enabled = true;
        speed = 1.6;
        bezier = "menu_accel";
      }
      {
        leaf = "fadeLayersIn";
        enabled = true;
        speed = 2.0;
        bezier = "menu_decel";
      }
      {
        leaf = "fadeLayersOut";
        enabled = true;
        speed = 4.5;
        bezier = "menu_accel";
      }
      {
        leaf = "workspaces";
        enabled = true;
        speed = 5.0;
        bezier = "wind";
      }
      {
        leaf = "specialWorkspace";
        enabled = true;
        speed = 3.0;
        bezier = "md3_decel";
        style = "slidevert";
      }
      {
        leaf = "border";
        enabled = true;
        speed = 1.0;
        bezier = "liner";
      }
      {
        leaf = "borderangle";
        enabled = true;
        speed = 30;
        bezier = "liner";
        style = "loop";
      }
    ];
  };
}
