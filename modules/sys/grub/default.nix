{ pkgs, ... }:

let
  # The same weight the splash and the greeter use. GRUB gets its own .pf2
  # conversions of it — see theme.nix.
  font = "${pkgs.nerd-fonts.space-mono}/share/fonts/truetype/NerdFonts/SpaceMono/SpaceMonoNerdFont-Regular.ttf";

  sprites = pkgs.callPackage ../saturn-stage/sprites.nix {
    wallpaper = ../../user/quickshell/qs/saturn-rings.jpg;
    inherit font;
    # BOOT rather than a SELECT of its own, and not only because there is no
    # LUKS prompt at this stage to need the other one: the splash opens on this
    # same badge, so reusing it means the lockup is pixel-identical across the
    # handover and simply stays put instead of changing word under the user.
    badges = [ "BOOT" ];
  };

  saturn = pkgs.callPackage ./theme.nix { inherit sprites font; };
in
{
  # GRUB rather than systemd-boot, for the one reason that systemd-boot cannot
  # be themed at all: it is a UEFI text console with no background, font or
  # colour of its own, so the generation menu stayed white-on-black while the
  # splash and the greeter did not. GRUB has a real theme engine.
  #
  # The price, all of it paid knowingly: the flat generation list becomes
  # "NixOS" plus a "NixOS - All configurations" submenu, and boot counting and
  # `bootctl`'s one-shot controls go away. `systemctl reboot --firmware-setup`
  # still works — that is an EFI variable, not a bootloader feature.
  boot.loader.grub = {
    enable = true;
    efiSupport = true;

    # EFI: there is no boot sector to install into.
    device = "nodev";

    theme = "${saturn}/share/grub/themes/saturn";

    # Not a splash in the usual sense — this is what gfxterm clears to, and it
    # is what keeps the black box off the screen.
    #
    # gfxterm owns the display whenever the menu does not: between views, as the
    # menu is left to boot, and for anything GRUB has to print. On a clear it
    # either blits a background bitmap or fills with default_bg_color, which is
    # black. install-grub.pl emits this image as a top-level `background_image`
    # (and `insmod png`), so it becomes that bitmap. The blit uses the same
    # source and destination coordinates, so the image is not squashed into the
    # terminal window — the window is repainted with exactly its own slice of
    # the stage, and the clear becomes invisible.
    #
    # Paired with the full-screen terminal rect in theme.txt, which is what
    # widens that repaint to cover the menu furniture as well.
    splashImage = "${sprites}/background.png";

    # The fallback behind the above: default_bg_color, used if the bitmap ever
    # fails to load. Style.scrim rather than black, so the failure mode is a
    # dark navy that nearly matches the stage instead of an obvious hole — and
    # is distinguishable from it when diagnosing.
    backgroundColor = "#05070a";

    # The panel is 1920x1080, which is also Style.designWidth/Height, so the
    # theme lands at native scale and nothing is resampled. Named explicitly
    # because the default "auto" is whatever the firmware offers first.
    gfxmodeEfi = "1920x1080,auto";

    # gfxpayloadEfi defaults to "keep", which is what makes the handover to
    # Plymouth seamless: the kernel inherits this framebuffer, and the splash
    # draws the same background into it.

    configurationLimit = 20;
    timeoutStyle = "menu";

    # systemd-boot synthesised this entry; GRUB does not.
    extraEntries = ''
      menuentry "UEFI Firmware Settings" --class efi {
        fwsetup
      }
    '';
  };
}
