{ ... }:

{
  # power-profiles-daemon already reaches this machine, but only as a side
  # effect of services.desktopManager.gnome.enable in gnome.nix. The quickshell
  # chip talks to it directly over the system bus, so ask for it here rather
  # than letting the stack rest on the desktop module staying enabled.
  #
  # Switching profiles needs no privilege of its own: the daemon's polkit
  # action is allow_active, so the write lands from the session that owns the
  # seat without a prompt.
  services.power-profiles-daemon.enable = true;
}
