{ pkgs, ... }:

let
  # Opening a terminal while another one is focused should continue where that
  # one left off. Kitty remote control would also do this, but it needs an IPC
  # socket per terminal and only covers kitty — /proc answers the same question
  # for any terminal and needs no terminal-side config.
  hypr-terminal = pkgs.writeShellApplication {
    name = "hypr-terminal";
    runtimeInputs = with pkgs; [
      hyprland # hyprctl; same store path the NixOS module already installs
      jq
      kitty
    ];
    text = ''
      # window-tags.nix already tags every terminal class; tags applied by a
      # window rule come back with a trailing "*", hence the rtrimstr.
      pid=$(hyprctl activewindow -j 2>/dev/null \
        | jq -r 'select((.tags // []) | any(rtrimstr("*") == "terminal")) | .pid // empty' \
        || true)

      cwd=""
      children="/proc/$pid/task/$pid/children"
      if [ -n "$pid" ] && [ -r "$children" ]; then
        kids=()
        read -ra kids < "$children" || true # no trailing newline in this file

        # The terminal process itself stays in $HOME — the interesting directory
        # belongs to whatever holds the foreground of its pty. Each child's stat
        # carries tpgid (field 8) = the fg process group of its controlling tty,
        # which points at the running command, or at the shell itself when idle.
        # Kitty's `kitten` helpers have no tty and report -1, so they drop out.
        for child in "''${kids[@]}"; do
          stat=$(cat "/proc/$child/stat" 2>/dev/null) || continue
          # comm may contain spaces and parens, so cut past the last ")"
          read -ra fields <<< "''${stat##*') '}"
          tpgid="''${fields[5]}"
          [ "$tpgid" -gt 0 ] 2>/dev/null || continue
          candidate=$(readlink "/proc/$tpgid/cwd" 2>/dev/null) || continue
          # guards against a deleted cwd, which readlink reports as "… (deleted)"
          [ -d "$candidate" ] && cwd="$candidate"
        done
      fi

      if [ -n "$cwd" ]; then
        exec kitty --directory "$cwd"
      fi
      exec kitty
    '';
  };
in
{
  home.packages = [ hypr-terminal ];
}
