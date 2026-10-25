{
  config,
  lib,
  pkgs,
  ...
}:

# The login screen: greetd running a Quickshell greeter, replacing GDM.
#
# The greeter is the same QML tree as the bar, so the login screen and the
# desktop are visibly one system. Two facts about *where* it runs shape
# everything below.
#
# First, greetd runs the greeter as an unprivileged `greeter` user, which
# cannot read /home/hcabel. The hot-reload symlink that serves the bar
# (modules/user/quickshell/default.nix) is therefore useless here, and the tree
# has to be published into the store instead — see environment.etc below. The
# cost is that greeter QML edits need a rebuild, unlike the bar's.
#
# Second, this machine has two GPUs and only the Intel one drives the laptop
# panel (see hosts/msi-laptop/gpu.nix). AQ_DRM_DEVICES is what tells aquamarine
# so, and it currently lives in hcabel's own Hyprland config, which the greeter
# does not read. Without it here, the greeter's compositor picks the wrong card
# and you get a black panel with no way to log in.

let
  hyprland = config.programs.hyprland.package;

  # Every session this machine can start, as .desktop files. GDM used to read
  # this directory on our behalf; with greetd nobody does, so the list below is
  # built from it at build time.
  sessionDesktops = config.services.displayManager.sessionData.desktops;

  # Runs inside the greeter's compositor. When quickshell exits — which it does
  # once greetd has accepted a password and is ready to launch the session —
  # the compositor has to go with it, or greetd waits forever.
  greeterInner = pkgs.writeShellScript "saturn-greeter-inner" ''
    # Hyprland has already pointed its stdio at its own log under /run by the
    # time it runs this, and the child inherits it — so without the redirect a
    # greeter that fails to load leaves its reason in a file the next boot
    # deletes. Tagged apart from saturn-greeter so the shell's errors are not
    # buried in the compositor's debug log.
    ${config.systemd.package}/bin/systemd-cat -t saturn-greeter-qs \
      ${pkgs.quickshell}/bin/quickshell --no-color -p /etc/greetd/qs/greeter.qml
    exec ${hyprland}/bin/hyprctl dispatch exit
  '';

  greeterLua = pkgs.writeText "hyprland.lua" ''
    -- Throwaway compositor whose only job is to host the greeter surface.
    hl.monitor({
      output   = "",
      mode     = "preferred",
      position = "auto",
      scale    = "auto",
    })

    hl.config({
      animations = {
        enabled = false,
      },
      misc = {
        disable_hyprland_logo    = true,
        disable_splash_rendering = true,
        -- Matches Style.scrim, so the handoff from the splash has nothing to
        -- flash through.
        background_color         = "rgb(05070a)",
      },
      ecosystem = {
        -- hyprland-qtutils opens these as real windows. On a login screen that
        -- means a nag box on top of the password field after a version bump.
        no_update_news  = true,
        no_donation_nag = true,
      },
      input = {
        -- services.xserver.xkb does not reach Hyprland, so the greeter has to
        -- be told the layout separately or you type your password blind on a
        -- keymap you did not choose.
        kb_layout = "${config.services.xserver.xkb.layout}",
      },
    })

    hl.on("hyprland.start", function()
      hl.exec_cmd("${greeterInner}")
    end)
  '';

  greeterSession = pkgs.writeShellScript "saturn-greeter" ''
    export XDG_CONFIG_HOME=/etc/greetd/config

    # See the header. Guarded rather than unconditional so that the VM build,
    # where the udev rule in gpu.nix has no matching device, still starts.
    [ -e /dev/dri/igpu ] && export AQ_DRM_DEVICES=/dev/dri/igpu

    # greetd hands the session process the VT as its stdio, so anything
    # Hyprland prints on the way up lands on tty1 as visible text in the gap
    # between the splash quitting and the compositor taking over the display.
    # Blank the console while it is still ours, then hand stdout and stderr to
    # the journal — which is also the only reason `journalctl -t saturn-greeter`
    # has anything in it at all. Before this the greeter's QML warnings went to
    # a terminal nobody reads.
    printf '\033[2J\033[H\033[?25l' >&2

    exec ${config.systemd.package}/bin/systemd-cat -t saturn-greeter \
      ${hyprland}/bin/start-hyprland
  '';

  # The same treatment, for the session the greeter hands over to. greetd gives
  # every session process the VT as its stdio, not just the greeter, so a
  # compositor coming up prints over the display it is about to take — and uwsm
  # is considerably more talkative on the way up than start-hyprland is, a dozen
  # lines of unit-directory bookkeeping before Hyprland says anything at all.
  # The greeter has been blanking the console since it was written; the session
  # never did, which is the terminal text visible between the two.
  #
  # Takes the journal tag as its first argument and the real argv after it, so
  # one script covers every entry in sessionsJson rather than each session
  # needing a wrapper of its own.
  sessionWrapper = pkgs.writeShellScript "saturn-session" ''
    printf '\033[2J\033[H\033[?25l' >&2

    tag="$1"
    shift

    exec ${config.systemd.package}/bin/systemd-cat -t "$tag" "$@"
  '';

  # Everything the greeter needs to know about this machine. Generated rather
  # than written into the QML because that tree is also mirrored into ~/nixos
  # for hot reload, and store paths must not leak into it.
  sessionsJson =
    pkgs.runCommand "greetd-sessions.json"
      {
        nativeBuildInputs = [ pkgs.jq ];

        user = "hcabel";
        nixosRelease = config.system.nixos.release;
        keymap = config.services.xserver.xkb.layout;

        # Which entry a fresh greeter starts on. Sorting is otherwise
        # alphabetical, which would put GNOME first and mean that pressing
        # Enter without looking lands in the wrong desktop.
        preferred = "hyprland-uwsm";
      }
      ''
        : > entries

        for f in ${sessionDesktops}/share/wayland-sessions/*.desktop; do
          id=''${f##*/}
          id=''${id%.desktop}

          # Anchored, and first match only. gnome.desktop carries about a
          # hundred Name[xx]= translations, and an unanchored match returns
          # whichever language happens to sort first — Abkhaz, as it turns out.
          name=$(sed -n 's/^Name=//p' "$f" | head -n1)
          exec=$(sed -n 's/^Exec=//p' "$f" | head -n1)
          desktop=$(sed -n 's/^DesktopNames=//p' "$f" | head -n1)

          [ -n "$exec" ] || continue

          # greetd is handed argv, not a shell string, so Exec is split here.
          # Every session on this machine has space-free arguments; the %-codes
          # the desktop entry spec allows are dropped rather than passed on.
          #
          # Exec goes behind sessionWrapper, with the session id as the journal
          # tag, so nothing a compositor prints on the way up reaches tty1.
          #
          # The XDG variables matter: hyprland-uwsm sets its own via uwsm, but
          # gnome.desktop is a bare gnome-session that GDM would normally have
          # launched with this environment already in place.
          jq -nc \
            --arg id "$id" \
            --arg label "''${name:-$id}" \
            --arg exec "$exec" \
            --arg desktop "$desktop" \
            --arg wrapper "${sessionWrapper}" \
            '{
               id: $id,
               label: $label,
               command: ([$wrapper, $id] + ($exec | split(" ") | map(select(length > 0 and (startswith("%") | not))))),
               environment: (
                 [ "XDG_SESSION_TYPE=wayland", "XDG_SESSION_DESKTOP=\($id)" ]
                 + (if $desktop == "" then [] else [ "XDG_CURRENT_DESKTOP=\($desktop)" ] end)
               )
             }' >> entries
        done

        # sort_by is stable, so the second sort only lifts the preferred entry
        # to the front and leaves the rest alphabetical.
        jq -s \
          --arg user "$user" \
          --arg nixosRelease "$nixosRelease" \
          --arg keymap "$keymap" \
          --arg preferred "$preferred" \
          '{
             user: $user,
             nixosRelease: $nixosRelease,
             keymap: $keymap,
             sessions: (sort_by(.id) | sort_by(.id != $preferred))
           }' entries > $out
      '';

  # The greeter tree is published into the store rather than symlinked (see the
  # header), so a qmldir entry naming a file that is not in the store breaks
  # nothing at build time — it produces a login screen that loads no surface at
  # all and shows the compositor's background colour, with the QML error going
  # nowhere. The usual cause is a component that was written but never
  # `git add`ed, which leaves the flake unable to see it while the qmldir edit
  # registering it sails through.
  #
  # Checked here so that mistake is a failed rebuild rather than a machine you
  # cannot log into.
  greeterQs = pkgs.runCommandLocal "greetd-qs" { src = ../../user/quickshell/qs; } ''
    missing=
    for qmldir in $(find $src -name qmldir); do
      dir=$(dirname "$qmldir")

      # Every type line ends in the file backing it; module/plugin/depends
      # lines and comments do not, so the suffix is the whole filter.
      while read -r line || [ -n "$line" ]; do
        file=''${line##* }
        case "$file" in
          *.qml) [ -e "$dir/$file" ] || missing="$missing ''${dir#$src/}/$file" ;;
        esac
      done < "$qmldir"
    done

    if [ -n "$missing" ]; then
      echo "greeter QML tree is incomplete - these qmldir entries have no file:" >&2
      for f in $missing; do echo "  $f" >&2; done
      echo >&2
      echo "If you just created them they are untracked: git add them so the flake can see them." >&2
      exit 1
    fi

    cp -r $src $out
  '';
in
{
  services.greetd = {
    enable = true;

    settings.default_session = {
      command = "${greeterSession}";
      user = "greeter";
    };
  };

  # Hold the last splash frame in the framebuffer instead of dropping to a bare
  # console, so there is no black gap while Hyprland comes up and takes over
  # the display. Paired with the stdio redirection in greeterSession above —
  # retaining the splash over a console that is still printing would only make
  # the flash harder to read.
  # The leading "-" is the package unit's, kept: quitting a plymouth that is not
  # running is not a reason to report a failed unit at every boot.
  systemd.services.plymouth-quit.serviceConfig.ExecStart = lib.mkForce [
    ""
    "-${config.boot.plymouth.package}/bin/plymouth quit --retain-splash"
  ];

  # The greeter's copy of the shell. Read-only, world-readable, and identical
  # to what the bar runs, so components stay shared rather than forked.
  environment.etc."greetd/qs".source = greeterQs;
  environment.etc."greetd/config/hypr/hyprland.lua".source = greeterLua;
  environment.etc."greetd/sessions.json".source = sessionsJson;

  # The greetd module leaves this user on /var/empty. Qt and quickshell both
  # want somewhere writable to put a cache, so give it a real home — which is
  # also where the greeter remembers the last session picked.
  users.users.greeter = {
    home = "/var/lib/greeter";
    createHome = true;
    homeMode = "0700";

    # logind grants DRM and input by uaccess ACL once the session is registered,
    # so this is belt and braces — but a greeter that cannot open the GPU is a
    # machine you cannot log into, and the cost here is nothing.
    extraGroups = [
      "video"
      "input"
    ];
  };
}
