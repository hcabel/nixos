{ lib, pkgs, ... }:

let
  inherit (import ./lib.nix lib) on;

  tags = import ./window-tags.nix;

  behaviour = {
    dialog = {
      float = true;
    };
  };

  tagRules = lib.concatLists (
    lib.mapAttrsToList (
      tag: classes:
      map (class: {
        match = { inherit class; };
        tag = "+${tag}";
      }) classes
    ) tags
  );

  behaviourRules = lib.mapAttrsToList (tag: effects: { match.tag = tag; } // effects) behaviour;

  knownPattern = lib.concatStringsSep "|" (lib.concatLists (lib.attrValues tags));

  hypr-window-logger = pkgs.writeShellApplication {
    name = "hypr-window-logger";
    runtimeInputs = with pkgs; [
      socat
      coreutils
      gnugrep
    ];
    text = ''
      known=${lib.escapeShellArg knownPattern}
      state="''${XDG_STATE_HOME:-$HOME/.local/state}/hypr"
      mkdir -p "$state"
      log="$state/untagged-windows.tsv"
      touch "$log"

      sock="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

      socat -U - "UNIX-CONNECT:$sock" | while IFS= read -r line; do
        [[ "$line" == openwindow\>\>* ]] || continue
        payload="''${line#openwindow>>}"

        class=$(printf '%s' "$payload" | cut -d, -f3)
        title=$(printf '%s' "$payload" | cut -d, -f4-)
        [ -n "$class" ] || class="(no-class)"

        # already tagged?
        if [ -n "$known" ] && printf '%s' "$class" | grep -qE "$known"; then
          continue
        fi
        # already recorded?
        if cut -f1 "$log" | grep -qxF "$class"; then
          continue
        fi

        printf '%s\t%s\t%s\n' "$class" "$title" "$(date -Is)" >> "$log"
      done
    '';
  };
in
{
  home.packages = [ hypr-window-logger ];

  wayland.windowManager.hyprland.settings = {
    window_rule = tagRules ++ behaviourRules;
    on = [ (on "hyprland.start" ''hl.exec_cmd("hypr-window-logger")'') ];
  };
}
