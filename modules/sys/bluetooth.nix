{ ... }:

{
  # bluez already reaches this machine, but only as a side effect of
  # services.desktopManager.gnome.enable in gnome.nix. The quickshell panel
  # talks to it directly over the system bus, so ask for it here rather than
  # letting the stack rest on the desktop module staying enabled.
  hardware.bluetooth = {
    enable = true;

    # Powers the adapter when bluez starts. Note this does not clear an rfkill
    # soft block — that is a kernel kill switch, and the panel's own switch
    # clears it through /dev/rfkill before writing Powered.
    powerOnBoot = true;
  };

  # Quickshell's Bluetooth API has pair() and cancelPair() but no agent hook,
  # so a device that asks for a PIN has nothing to answer it. blueman supplies
  # the session agent; blueman-applet is started from hypr/autostart.nix.
  services.blueman.enable = true;
}
