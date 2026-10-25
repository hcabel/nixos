{ pkgs, ... }:

let
  # boot.plymouth.font below takes a single file, and this is it: the initrd
  # gets exactly one weight. Anything bold or letterspaced in the theme is
  # pre-rendered rather than asked for at boot — see theme.nix.
  font = "${pkgs.nerd-fonts.space-mono}/share/fonts/truetype/NerdFonts/SpaceMono/SpaceMonoNerdFont-Regular.ttf";

  sprites = pkgs.callPackage ../saturn-stage/sprites.nix {
    # The same file the bar, hyprpaper and the greeter draw, so all three
    # stages of the boot share one image rather than three copies that drift.
    wallpaper = ../../user/quickshell/qs/saturn-rings.jpg;

    inherit font;

    # UNLOCK replaces BOOT while the LUKS passphrase is being asked for.
    badges = [
      "BOOT"
      "UNLOCK"
    ];
  };

  saturn = pkgs.callPackage ./theme.nix { inherit sprites font; };
in
{
  # Load the Intel driver in the initrd so the splash comes up on the panel's
  # real mode. Without it Plymouth starts on the EFI simpledrm framebuffer and
  # visibly re-modesets when i915 loads in stage 2.
  #
  # Lives here rather than in hardware.nix, which is generated and carries a
  # "do not modify" header, and this is a splash concern rather than a
  # hardware-detection one. It does not disturb the ID_PATH udev rule in
  # gpu.nix: that matches the iGPU exactly and still will not bind simpledrm.
  boot.initrd.kernelModules = [ "i915" ];

  boot.plymouth = {
    enable = true;

    theme = "saturn";
    themePackages = [ saturn ];

    inherit font;
  };
}
