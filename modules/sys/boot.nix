{ ... }:

{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Pinned rather than changed: this is already the default in nixpkgs 26.05,
  # and this machine has been booting on the systemd initrd all along. It is
  # named explicitly because the splash depends on it — under the classic
  # scripted initrd, plymouth.nix starts plymouthd *after* the LUKS prompt, so
  # the passphrase would be asked for on a bare console and only then would the
  # splash appear. It is also the prerequisite for TPM unlock later.
  boot.initrd.systemd.enable = true;

  # The splash owns the screen from here on (modules/sys/plymouth), so the
  # console should stay quiet underneath it. `splash` itself is appended
  # automatically by boot.plymouth.enable.
  #
  # Deliberately NOT set: systemd.show_status=false. It looks like it belongs
  # here, but the splash's scrolling list is fed by the same unit-status
  # channel, so silencing status would empty the one part of the boot screen
  # that is actually alive.
  boot.consoleLogLevel = 3; # errors and worse still reach the console

  boot.kernelParams = [
    "quiet"
    "udev.log_level=3"
    "rd.udev.log_level=3"

    # Otherwise a text cursor blinks on top of the splash.
    "vt.global_cursor_default=0"
  ];
}
