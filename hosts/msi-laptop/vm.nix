{ ... }:

# `nixos-rebuild build-vm` builds this host in a VM, which is the only safe way
# to try a change to the login path: if the greeter does not come up you close
# the window instead of rebooting into a machine you cannot log into.
#
# Only applies to the VM build — vmVariant is inert on the real system.
{
  virtualisation.vmVariant = {
    virtualisation.resolution = {
      x = 1920;
      y = 1080;
    };

    virtualisation.memorySize = 4096;
    virtualisation.cores = 4;

    # The VM gets a fresh /etc/shadow, so the account the greeter authenticates
    # against has no password at all unless one is set here.
    users.users.hcabel.password = "test";

    # Graphical console only. The VM would otherwise get console=ttyS0 as well,
    # and Plymouth forces its plain-text "details" view whenever it detects a
    # serial console — so the splash this repo exists to build would never be
    # visible in the one place it is safe to preview.
    virtualisation.qemu.consoles = [ "tty0" ];
  };
}
