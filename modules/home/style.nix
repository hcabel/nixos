{ lib, ... }:

# The single source of truth for every colour and dimension in the desktop.
#
# This is the "rose" design system (~/Downloads/Rose Design System). Values here
# are transcribed from tokens/*.css; readme.md carries the rules and
# guidelines/*.card.html document each group.
#
# Freeform on purpose: add a key below and it reaches QML with no other edit —
# but it still needs a rebuild, because style.json is generated into the store.
# The whole tree is serialised verbatim by modules/home/quickshell/default.nix
# and qs/Style.qml parses it generically; neither names individual values.
# Nix consumers (hyprland, wl-kbptr, terminal) read config.hcabel.style directly.
#
# Two tiers reach consumers, and the distinction matters — across all 40
# components in the design system, the raw tier is referenced zero times:
#
#   rose.*   raw hue anchors. Positional names, not literal (in a light theme
#            `cream` is the dark one). Avoid; they are here for reference.
#   the rest — the semantic tier. Bind to this.
#
# The design system's alpha ramps (--tint-*, --ink-*) are NOT emitted: every one
# of their rungs already has a semantic name, and one name per value beats two.
#   --ink-03/06/08   -> bg.press / bg.rest / bg.hover
#   --ink-12/18      -> hairline.chip / hairline.emphasis
#   --tint-<hue>-*   -> accent.<role>.{wash,tintFill,active,line}
#
# Ladders are lists; anything whose rungs carry meaning is named. sizes.gap is
# ordered, so it is a real list. sizes.height and radius are not — the design
# system assigns every one of their rungs a job, so they are named by that job.

let
  inherit (lib)
    toHexString
    fixedWidthString
    removePrefix
    toLower
    ;

  # 0..1 alpha + "#rrggbb" -> Qt's "#aarrggbb". Every rgba() in the design
  # system becomes one value QML can use directly; nothing composes alpha at a
  # call site. Nix consumers wanting #rrggbbaa reorder it locally.
  a =
    alpha: hex:
    "#"
    + toLower (fixedWidthString 2 "0" (toHexString (builtins.floor (alpha * 255 + 0.5))))
    + removePrefix "#" hex;

  hexDigit = {
    "0" = 0;
    "1" = 1;
    "2" = 2;
    "3" = 3;
    "4" = 4;
    "5" = 5;
    "6" = 6;
    "7" = 7;
    "8" = 8;
    "9" = 9;
    "a" = 10;
    "b" = 11;
    "c" = 12;
    "d" = 13;
    "e" = 14;
    "f" = 15;
  };

  # byte i of "#rrggbb" as an int (i = 0 red, 1 green, 2 blue)
  channel =
    hex: i:
    let
      d = toLower (removePrefix "#" hex);
      at = n: hexDigit.${builtins.substring n 1 d};
    in
    at (i * 2) * 16 + at (i * 2 + 1);

  toByte = n: toLower (fixedWidthString 2 "0" (toHexString n));

  # Composite `fg` over `bg` at `alpha`, producing an opaque "#rrggbb".
  # For consumers that cannot express alpha at all — ghostty's selection colour
  # is the case that forces this.
  blend =
    alpha: fg: bg:
    "#"
    + builtins.concatStringsSep "" (
      map (i: toByte (builtins.floor (alpha * channel fg i + (1 - alpha) * channel bg i + 0.5))) [
        0
        1
        2
      ]
    );

  # ── tier 1 — raw palette ────────────────────────────────────────────────
  rose = {
    void = "#16181a";
    base = "#1e2023";
    surface = "#2a2d31";
    raised = "#33373c";

    pink = "#f23e96";
    turquoise = "#12d6de";
    gold = "#e0a855";

    cream = "#faf3e6";
    muted = "#a9a29a";
  };

  # ── tier 1.5 — alpha ramps ──────────────────────────────────────────────
  # 08 wash · 16 fill · 24 active fill · 42 hairline
  tintOf = hex: {
    "08" = a 0.08 hex;
    "16" = a 0.16 hex;
    "24" = a 0.24 hex;
    "42" = a 0.42 hex;
  };

  # Neutral overlays. Hover is white, never accent — accent already means
  # "selected", and one signal cannot mean two things.
  ink = {
    "03" = a 0.03 rose.cream; # press
    "06" = a 0.06 rose.cream; # rest fill
    "08" = a 0.08 rose.cream; # hover fill, divider hairline
    "12" = a 0.12 rose.cream; # chip/control hairline
    "18" = a 0.18 rose.cream; # emphasis hairline
  };

  # ── tier 2 — semantic ───────────────────────────────────────────────────
  bg = {
    base = rose.base; # desktop, page
    surface = rose.surface; # cards, panels
    raised = rose.raised; # menus, toasts
    inset = rose.void; # fields, insets
    # Neutral overlay ladder. Hover adds white, never accent — accent already
    # means "selected", and one signal cannot mean two things.
    #
    # The design system disagrees with itself on these two: colors.css declares
    # --bg-hover as var(--ink-06), but readme.md ("6% at rest, 8% on hover …
    # press drops to 3%") and the colors-hairlines card ("--ink-06 rest,
    # --ink-08 hover") both say otherwise. Following the readme and the card —
    # a rest/hover pair that differ is the only reading where the hover rule
    # means anything. Don't "fix" this back to 6%.
    rest = ink."06";
    hover = ink."08";
    press = ink."03";
    # "this surface is temporary and floats over your work" — bar, panels, OSD,
    # context menus. Cards, windows and rows are never glass.
    glass = a 0.62 rose.surface;
  };

  # Six steps, nothing between them. Any grey not on this ramp is a bug.
  text = {
    primary = rose.cream; # names, values, headlines
    body = a 0.85 rose.cream; # prose, row labels
    secondary = rose.muted; # meta, units
    tertiary = a 0.42 rose.cream; # section labels
    quiet = a 0.28 rose.cream; # hints, dBm
    absent = a 0.18 rose.cream; # empty slots
    onAccent = rose.base; # the one solid-accent case
  };

  hairline = {
    base = ink."08"; # divider
    chip = ink."12"; # chip, control
    emphasis = ink."18";
    gold = a 0.42 rose.gold; # the one warm structural border, ~once per screen
  };

  # Shadow means a thing is above the base; glow means it is emitting.
  # Only accents glow — neutral surfaces never do.
  glow = {
    pink = {
      blur = 20;
      color = a 0.38 rose.pink;
    };
    turquoise = {
      blur = 20;
      color = a 0.34 rose.turquoise;
    };
    gold = {
      blur = 16;
      color = a 0.30 rose.gold;
    };
  };

  # Wider, softer — background washes. There is no gold bloom.
  bloom = {
    pink = {
      blur = 26;
      color = a 0.26 rose.pink;
    };
    turquoise = {
      blur = 26;
      color = a 0.22 rose.turquoise;
    };
  };

  # {fill, line, text, glow} is the design system's own per-accent contract —
  # every component destructures exactly those four keys. wash/tintFill/active
  # are the 08/16/24 rungs, named by job.
  #
  # Accents are never solid behind text (sole exception: a count badge).
  # Elsewhere an accent is a tint + a 42% hairline + a glow. That is what keeps
  # a 15-20% accent budget from reading as 50%.
  accentOf = hex: ramp: g: {
    fill = hex;
    # Identical to `fill` in dark. The pair exists because light mode splits
    # fill-grade from text-grade; bind text to this and a light theme is additive.
    text = hex;
    line = ramp."42";
    wash = ramp."08";
    tintFill = ramp."16";
    active = ramp."24";
    glow = g;
  };
in
{
  options.hcabel.style = lib.mkOption {
    type = lib.types.submodule { freeformType = with lib.types; attrsOf anything; };
    default = { };
    description = "Shared theme values. Add a key here and it reaches QML with no other edit.";
  };

  # Plain definitions, not defaults — a host overriding a leaf needs lib.mkForce.
  config.hcabel.style = {

    # ── font ──────────────────────────────────────────────────────────────
    # Space Mono is the only face: display, body, UI and terminal. Weights are
    # 400 and 700 only — the face has no 600, so anywhere a spec says 600, use
    # 700. Weight never animates.
    font = {
      mono = "SpaceMono Nerd Font";
      display = "SpaceMono Nerd Font";
      body = "SpaceMono Nerd Font";
      terminal = "SpaceMono Nerd Font";
      size = 14;
      weight = {
        regular = 400;
        bold = 700;
      };
    };

    # ── type ──────────────────────────────────────────────────────────────
    # px, because the shell is px-bound. Mono needs negative tracking above
    # 26px and positive tracking on small-caps labels.
    type = {
      size = {
        "2xs" = 10;
        xs = 11;
        sm = 12.5;
        base = 14;
        md = 16;
        lg = 20;
        xl = 26;
      };

      display = {
        sm = 34;
        md = 44;
        lg = 60;
        xl = 80;
      };

      lh = {
        tight = 1.05;
        snug = 1.25;
        body = 1.55;
        loose = 1.7;
      };

      # em, unitless
      track = {
        display = -0.03;
        heading = -0.015;
        body = 0.0;
        label = 0.08;
        tag = 0.06;
      };

      # The shell uses EXACTLY these two: 12.5/700 names the thing,
      # 11/400 says everything else.
      chromeName = {
        weight = 700;
        size = 12.5;
        lh = 1.0;
      };
      chromeMeta = {
        weight = 400;
        size = 11;
        lh = 1.0;
      };

      # Role shorthands for the wider system.
      role = {
        display = {
          weight = 700;
          size = 60;
          lh = 1.05;
        };
        h1 = {
          weight = 700;
          size = 34;
          lh = 1.25;
        };
        h2 = {
          weight = 700;
          size = 26;
          lh = 1.25;
        };
        h3 = {
          weight = 700;
          size = 20;
          lh = 1.25;
        };
        body = {
          weight = 400;
          size = 14;
          lh = 1.55;
        };
        meta = {
          weight = 400;
          size = 12.5;
          lh = 1.25;
        };
        # Uppercase belongs here and in section labels only. Never on a
        # control, never in prose — and applied by the renderer, never typed.
        label = {
          weight = 700;
          size = 10;
          lh = 1.2;
        };
        tag = {
          weight = 700;
          size = 9;
          lh = 1.0;
        };
      };
    };

    # ── sizes ─────────────────────────────────────────────────────────────
    sizes = {
      # An ordered ladder, so it is an actual list. Indices 0-6 are the shell's
      # seven gaps — "nothing between the steps". 7-11 are the extended layout
      # rungs, which only the web surfaces use.
      #
      # The three that have a job of their own are named below: gutter (6),
      # panelPad (12). 18 and 22 separate blocks; 9 is row padding and row gaps.
      gap = [
        2
        4
        6
        9
        12
        18
        22

        32
        48
        64
        96
        128
      ];

      # Not a ladder — "control size carries meaning: where it lives sets how
      # tall it is". So these are named, not indexed. 24 and 30 do not exist.
      height = {
        rowAction = 20; # an action inside a list row
        panelControl = 22; # every control inside a panel
        barControl = 26; # top bar only
        row = 34; # list row, field
        bar = 44; # the bar itself, an owned device
        rowMeter = 56; # two-line row with a meter
      };

      titlebarHeight = 26;
      hitMin = 44;

      gutter = 6;
      panelPad = 12;
      panelWidth = 340;
      contentMax = 1140;

      strokeHair = 1;
      strokeIcon = 1.3;

      # 10 in a chip, 13 in a row, 15 in a tile. Never above 22 in the shell.
      icon = {
        grid = 16;
        sm = 10;
        md = 13;
        lg = 15;
      };

      # Extensions — not rose tokens. The outer frame rail is a concept the
      # design system does not have; shadowBands is a detail of the banded
      # fake-shadow renderer in qs/frame/FrameWindow.qml.
      rail = 10;
      fillet = 14;
      shadowBands = 24;
    };

    # ── radius ────────────────────────────────────────────────────────────
    # 2 tick · 4 tag · 6 menu item · 9 chip/row · 12 card · 18 panel/window.
    radius = {
      # Every rung of the 2·4·6·9·12·18 ladder has a job, so the ladder itself
      # is not emitted — these names are it.
      tick = 2;
      tag = 4;
      menu = 6;
      chip = 9;
      row = 9;
      card = 12;
      panel = 18;
      window = 18;

      pill = 999;
      pillCtl = 7; # the one off-ladder value

      # The signature: two corners sharp, two rounded. ONCE per screen, on the
      # single hero element (the terminal window, the primary CTA, the featured
      # card). Use it twice and it stops being a signature.
      signature = {
        topLeft = 4;
        topRight = 20;
        bottomRight = 4;
        bottomLeft = 20;
      };
      signatureCompact = {
        topLeft = 3;
        topRight = 14;
        bottomRight = 3;
        bottomLeft = 14;
      };
      signatureLarge = {
        topLeft = 8;
        topRight = 40;
        bottomRight = 8;
        bottomLeft = 40;
      };
    };

    # ── motion ────────────────────────────────────────────────────────────
    # One curve. Opacity, fill width, tint and translation animate.
    # Blur radius, panel geometry and font weight never do.
    motion = {
      # cubic-bezier(.32,.72,0,1), shaped for QML's easing.bezierCurve, which
      # wants the trailing 1,1 endpoint.
      ease = [
        0.32
        0.72
        0.0
        1.0
        1.0
        1.0
      ];
      easeLoop = "linear";

      dur = {
        tint = 120; # tint and text colour
        state = 200; # chip and button state
        open = 220; # lozenge stretch, panel open
        loop = 900; # spinner, patch-line flow — linear, not the system curve
        breath = 2600; # recording, urgent workspace
      };
    };

    # ── elevation ─────────────────────────────────────────────────────────
    elevation = {
      e1 = {
        x = 0;
        y = 6;
        blur = 18;
        color = a 0.38 "#000000";
      }; # window, toast, menu
      e2 = {
        x = 0;
        y = 18;
        blur = 46;
        color = a 0.55 "#000000";
      }; # panel

      insetField = {
        x = 0;
        y = 1;
        blur = 2;
        color = a 0.30 "#000000";
      };

      inherit glow bloom;

      blurPanel = 26;
      saturatePanel = 1.70;
    };

    # ── palette ───────────────────────────────────────────────────────────
    # Pink leads, turquoise supports, gold structures. Together they occupy
    # 15-20% of a layout; base, surface and neutral text carry the rest.
    palette = {
      inherit
        rose
        bg
        text
        hairline
        ;

      accent = {
        primary = accentOf rose.pink (tintOf rose.pink) glow.pink; # headlines, the one CTA
        secondary = accentOf rose.turquoise (tintOf rose.turquoise) glow.turquoise; # links, secondary
        structural = accentOf rose.gold (tintOf rose.gold) glow.gold; # borders, dividers

        neutral = {
          fill = bg.rest;
          text = text.body;
          line = hairline.chip;
          glow = null; # neutral surfaces never glow
        };
      };

      link = {
        base = rose.turquoise;
        hover = "#5fe6ec";
        visited = "#9ad9dc";
      };

      status = {
        critical = rose.pink;
        ok = rose.turquoise;
        warn = rose.gold;
        idle = rose.muted;
      };

      # 2px ring at 2px offset, never a colour swap.
      focusRing = a 0.55 rose.pink;
      scrim = a 0.62 rose.void;
    };

    # ── terminal ──────────────────────────────────────────────────────────
    # ANSI 16 derived from the palette: magenta is the brand pink, cyan the
    # turquoise, yellow the sandstone. Red/green/blue are the nearest members
    # of those same hue families so a terminal reads as the same brand.
    terminal = {
      bg = rose.base;
      fg = rose.cream;
      cursor = rose.pink;
      selection = a 0.28 rose.pink;
      # Same colour, pre-composited over the terminal background, for consumers
      # that cannot express alpha (ghostty selection-background).
      selectionSolid = blend 0.28 rose.pink rose.base;
      bgAlt = rose.surface;
      dim = rose.muted;

      ansi = [
        "#1e2023" # 0  black
        "#e8455f" # 1  red
        "#3fd9a0" # 2  green
        "#e0a855" # 3  yellow   — sandstone
        "#37a6d9" # 4  blue
        "#f23e96" # 5  magenta  — brand pink
        "#12d6de" # 6  cyan     — brand turquoise
        "#d9d1c4" # 7  white
        "#4a4f55" # 8  bright black
        "#ff6b80" # 9  bright red
        "#6ff0c0" # 10 bright green
        "#f0c57e" # 11 bright yellow
        "#6fc9ee" # 12 bright blue
        "#ff77b6" # 13 bright magenta
        "#6bedf2" # 14 bright cyan
        "#faf3e6" # 15 bright white
      ];
    };
  };
}
