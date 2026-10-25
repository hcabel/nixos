{ ... }:

{
  # The login manager lives in modules/sys/greeter now — gdm and greetd both
  # alias display-manager.service, so enabling both fails to build. GNOME
  # itself does not need GDM: it only contributes its session to the list the
  # greeter offers.
  services.desktopManager.gnome.enable = true;

  services.xserver.enable = true;
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };
}
