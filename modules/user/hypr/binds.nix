{ lib, pkgs, ... }:

let
  inherit (import ./lib.nix lib) bind bindOpts;

  mod = "SUPER";

  workspaceBinds = builtins.concatLists (
    builtins.genList (
      i:
      let
        ws = toString (i + 1);
        key = toString (if i + 1 == 10 then 0 else i + 1);
      in
      [
        (bind "${mod} + ${key}" "hl.dsp.focus({ workspace = ${ws} })")
        (bind "${mod} + CTRL + ${key}" "hl.dsp.window.move({ workspace = ${ws} })")
      ]
    ) 10
  );

  terminal = "${pkgs.kitty}/bin/kitty";
in
{
  wayland.windowManager.hyprland.settings.bind = [
    # ── launching ──────────────────────────────────────────────────────────
    (bind "${mod} + Return" ''hl.dsp.exec_cmd("${terminal}")'')

    # ── window management ──────────────────────────────────────────────────
    (bind "${mod} + W" "hl.dsp.window.close()")
    (bind "${mod} + F" ''hl.dsp.window.float({ action = "toggle" })'')
    (bind "F11" ''hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" })'')
    (bind "${mod} + E" ''hl.dsp.layout("togglesplit")'')

    # focus
    (bind "${mod} + left" ''hl.dsp.focus({ direction = "left" })'')
    (bind "${mod} + right" ''hl.dsp.focus({ direction = "right" })'')
    (bind "${mod} + up" ''hl.dsp.focus({ direction = "up" })'')
    (bind "${mod} + down" ''hl.dsp.focus({ direction = "down" })'')

    # swap
    (bind "${mod} + ALT + left" ''hl.dsp.window.swap({ direction = "left" })'')
    (bind "${mod} + ALT + right" ''hl.dsp.window.swap({ direction = "right" })'')
    (bind "${mod} + ALT + up" ''hl.dsp.window.swap({ direction = "up" })'')
    (bind "${mod} + ALT + down" ''hl.dsp.window.swap({ direction = "down" })'')

    # ── groups ─────────────────────────────────────────────────────────────
    (bind "${mod} + G" "hl.dsp.group.toggle()")
    (bind "${mod} + ALT + G" "hl.dsp.window.move({ out_of_group = true })")
    (bind "${mod} + CTRL + left" "hl.dsp.group.prev()")
    (bind "${mod} + CTRL + right" "hl.dsp.group.next()")

    # Move the focused window into the group next to it, in that direction.
    (bind "${mod} + SHIFT + left" ''hl.dsp.window.move({ into_or_create_group = "left" })'')
    (bind "${mod} + SHIFT + right" ''hl.dsp.window.move({ into_or_create_group = "right" })'')

    # ── mouse ──────────────────────────────────────────────────────────────
    (bindOpts "${mod} + mouse:272" "hl.dsp.window.drag()" { mouse = true; })
    (bindOpts "${mod} + mouse:273" "hl.dsp.window.resize()" { mouse = true; })
    (bind "${mod} + S" ''hl.dsp.exec_cmd("hypr-kbptr detect")'')
    (bind "${mod} + SHIFT + S" ''hl.dsp.exec_cmd("hypr-kbptr grid")'')
  ]
  ++ workspaceBinds;
}
