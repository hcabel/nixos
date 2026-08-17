{
  config,
  lib,
  pkgs,
  ...
}:

let
  style = config.hcabel.style;
  p = style.palette;

  # Hyprland wants bare rrggbb inside rgb()/rgba(), not #rrggbb.
  hex = lib.removePrefix "#";
in
{
  imports = [
    ./binds.nix
    ./rules.nix
    ./wallpaper.nix
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    # The NixOS module owns the package so the portal and the compositor can
    # never drift apart.
    package = null;
    portalPackage = null;
    # Redundant with uwsm, and kept anyway. Everything the session needs —
    # dms, hypridle, hyprpolkitagent, sunshine — is bound to
    # graphical-session.target, and if whatever launched Hyprland didn't go
    # through uwsm then nothing ever starts that target and all of it silently
    # stays down. Letting Hyprland's own exec-once announce readiness makes the
    # session come up regardless of how it was started, which is worth more
    # than avoiding a duplicate `systemctl start` of an already-active target.
    systemd.enable = true;

    # Hyprland 0.55 deprecated hyprlang in favour of Lua, and home-manager
    # defaults to Lua at stateVersion 26.05. Pinned back to hyprlang because:
    #   - .conf is only loaded if hyprland.lua is ABSENT, so this must be an
    #     either/or choice, not a mix;
    #   - the theme engine generates hyprlang, and the Lua `hl.bind()` API
    #     takes structured dispatchers rather than the legacy single string,
    #     so every bind would need rewriting and revalidating;
    #   - upstream keeps .conf working "for a few releases".
    # Only Lua-only features (user-defined layouts) are given up, none of
    # which are used here. Migration is contained: the Hyprland generator in
    # modules/home/theme/generators.nix, plus binds.nix and rules.nix.
    configType = "hyprlang";

    settings = {
      # ── input ────────────────────────────────────────────────────────────
      input = {
        kb_layout = "us";
        kb_options = "compose:caps";
        repeat_rate = 40;
        repeat_delay = 600;
        follow_mouse = 1;
        numlock_by_default = true;
        sensitivity = 0;
        float_switch_override_focus = false;

        touchpad = {
          natural_scroll = true;
          disable_while_typing = true;
          clickfinger_behavior = true;
          tap-to-click = true;
          scroll_factor = 0.4;
        };
      };

      monitor = [ ", preferred, auto, 1" ];

      gesture = [
        "3, horizontal, workspace"
        "4, down, dispatcher, exec, dms ipc call hypr toggleOverview"
      ];

      # ── layout ───────────────────────────────────────────────────────────
      general = {
        layout = "dwindle";
        resize_on_border = true;

        gaps_out = 10; # Gaps between the inner content and the windows. (QS already har 10px gap)
        gaps_in = style.sizes.gap;

        # Saturn's blue → purple → pink border gradient.
        "col.active_border" = "rgb(${hex p.accent}) rgb(${hex p.accentMid}) rgb(${hex p.accentAlt}) 45deg";
        "col.inactive_border" = "rgb(${hex p.borderInactive})";
      };

      # ── decoration ───────────────────────────────────────────────────────
      decoration = {
        rounding = style.sizes.rounding;

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
          range = 24;
          render_power = 3;
          offset = "0 4";
          color = "rgba(${hex p.base}99)";
        };
      };

      group = {
        "col.border_active" = "rgb(${hex p.border})";
        "col.border_inactive" = "rgb(${hex p.borderInactive})";

        groupbar = {
          font_family = style.font.mono;
          font_size = 9;
          "col.active" = "rgb(${hex p.accent})";
          "col.inactive" = "rgb(${hex p.surface})";
          text_color = "rgb(${hex p.text})";
        };
      };

      animations = {
        enabled = true;

        bezier = [
          "wind, 0.05, 0.9, 0.1, 1.05"
          "winIn, 0.1, 1.1, 0.1, 1.1"
          "winOut, 0.3, -0.3, 0, 1"
          "liner, 1, 1, 1, 1"
          "md3_decel, 0.05, 0.7, 0.1, 1"
          "menu_decel, 0.1, 1, 0, 1"
          "menu_accel, 0.38, 0.04, 1, 0.07"
        ];

        animation = [
          "windows, 1, 6.0, wind, slide"
          "windowsIn, 1, 6.0, winIn, slide"
          "windowsOut, 1, 5.0, winOut, slide"
          "windowsMove, 1, 5.0, wind, slide"
          "fade, 1, 3.0, md3_decel"
          "layersIn, 1, 3.0, menu_decel, slide"
          "layersOut, 1, 1.6, menu_accel"
          "fadeLayersIn, 1, 2.0, menu_decel"
          "fadeLayersOut, 1, 4.5, menu_accel"
          "workspaces, 1, 5.0, wind"
          "specialWorkspace, 1, 3.0, md3_decel, slidevert"
          "border, 1, 1.0, liner"
          # Always-on rotating gradient border.
          "borderangle, 1, 30, liner, loop"
        ];
      };

      dwindle = {
        preserve_split = true;
        special_scale_factor = 0.8;
      };

      master = {
        new_status = "master";
        new_on_top = true;
        mfact = 0.5;
      };

      # ── behaviour ────────────────────────────────────────────────────────
      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        vrr = 2;
        mouse_move_enables_dpms = true;
        focus_on_activate = false;
        initial_workspace_tracking = 0;
        middle_click_paste = false;
        enable_anr_dialog = true;
        anr_missed_pings = 15;
        allow_session_lock_restore = true;
      };

      binds = {
        workspace_back_and_forth = false;
        allow_workspace_cycles = true;
        pass_mouse_when_bound = false;
      };

      cursor = {
        sync_gsettings_theme = true;
        enable_hyprcursor = true;
        inactive_timeout = 3;
        warp_on_change_workspace = 2;
        no_hardware_cursors = true;
      };

      xwayland.force_zero_scaling = true;

      ecosystem = {
        no_update_news = true;
        no_donation_nag = true;
      };

      # ── environment ──────────────────────────────────────────────────────
      env = [
        "XDG_CURRENT_DESKTOP,Hyprland"
        "XDG_SESSION_TYPE,wayland"
        "XDG_SESSION_DESKTOP,Hyprland"

        "GDK_BACKEND,wayland,x11,*"
        "QT_QPA_PLATFORM,wayland;xcb"
        "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
        "QT_AUTO_SCREEN_SCALE_FACTOR,1"
        "CLUTTER_BACKEND,wayland"
        "SDL_VIDEODRIVER,wayland"

        "MOZ_ENABLE_WAYLAND,1"
        "ELECTRON_OZONE_PLATFORM_HINT,auto"

        "GDK_SCALE,1"
        "QT_SCALE_FACTOR,1"

        "HYPRCURSOR_THEME,Bibata-Modern-Ice"
        "HYPRCURSOR_SIZE,24"
        "XCURSOR_THEME,Bibata-Modern-Ice"
        "XCURSOR_SIZE,24"
      ];

      # ── autostart ────────────────────────────────────────────────────────
      # hypridle is not here: it is a systemd user service, declared once in
      # modules/home/lock.nix (which also owns its config) and bound to
      # graphical-session.target. This list used to start it a second time from
      # a path that does not exist — hypridle ships in its own package, not in
      # Hyprland's — so the exec silently failed on every login.
      exec-once = [
        "[workspace 4 silent] firefox"
        "[workspace 6 silent] ${pkgs.ghostty}/bin/ghostty"
        # "[workspace 7 silent] ${pkgs.vesktop}/bin/vesktop"
      ];
    };

  };
}
