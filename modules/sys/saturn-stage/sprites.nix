{
  lib,
  stdenvNoCC,
  imagemagick,
  resvg,
  wallpaper,
  font,
  badges ? [ "BOOT" ],
}:

# The two parts of the Saturn stage that more than one boot stage has to draw:
# the scrimmed wallpaper, and the lockup that sits on top of it. Both are baked
# to pixels here rather than at boot, and both are shared rather than rebuilt
# per stage, because the stages hand over to each other on a live framebuffer —
# Plymouth inherits GRUB's, and the greeter inherits Plymouth's. Any difference
# in the geometry shows up as a visible step at the handover, so there is one
# copy of the arithmetic and everyone reads it.
#
# The composition is authored at 1920x1080 to match Style.designWidth/Height in
# the shell; each consumer scales from that to whatever mode the panel is in.
#
# `badges` names the pill at the right of the lockup, one output per entry:
# Plymouth wants BOOT and UNLOCK (it swaps them when it asks for the LUKS
# passphrase), GRUB only ever shows one.

stdenvNoCC.mkDerivation {
  pname = "saturn-stage-sprites";
  version = "1";

  src = lib.cleanSource ./.;

  nativeBuildInputs = [
    imagemagick
    resvg
  ];

  buildPhase = ''
    runHook preBuild
    mkdir -p build

    # --- background -----------------------------------------------------
    # The scrim is composited in here because a Plymouth sprite cannot hold a
    # gradient, and neither can a GRUB pixmap style.
    # Three stops on a 100 degree vector, matching greeter/Scrim.qml: 0.90 at
    # the near edge, 0.60 at 38%, 0.05 from 68% on.
    #
    # The geometry has to agree with the QML, or the wallpaper visibly steps
    # when the splash hands over to the login screen. CSS runs its gradient
    # over the box's projection onto the angle, which for 1920x1080 at 100
    # degrees is 1920*sin + 1080*|cos| = 2080px. So the ramp occupies 2080px
    # centred in a 3000px run, padded at both ends with the terminal values,
    # and the finished 1920 is cropped from the middle of that.
    magick \
      \( -size 2600x460 xc:'gray(90%)' \) \
      \( -size 2600x790 gradient:'gray(90%)-gray(60%)' \) \
      \( -size 2600x624 gradient:'gray(60%)-gray(5%)' \) \
      \( -size 2600x1126 xc:'gray(5%)' \) \
      -append -rotate -90 -distort SRT 10 +repage \
      -gravity center -extent 1920x1080 build/scrim-mask.png

    magick -size 1920x1080 xc:'#05070a' build/scrim-mask.png \
      -alpha off -compose copy_opacity -composite build/scrim.png

    magick ${wallpaper} -resize 1920x1080^ -gravity center -extent 1920x1080 \
      build/scrim.png -compose over -composite build/background.png

    # --- lockup ---------------------------------------------------------
    resvg assets/mark.svg -w 58 -h 48 build/mark-raw.png
    magick build/mark-raw.png -background none -gravity center -extent 66x66 build/mark.png

    magick -size 12x34 xc:none build/spacer.png
    magick -size 1x34 xc:'#3d3a45' build/divider.png

    magick -background none -fill '#99938a' -font ${font} -pointsize 11 \
      -kerning 3 label:'SATURN' build/wordmark.png

    badge() {
      # Authored tall and turned a quarter turn: ImageMagick gradients only run
      # top to bottom, and the rotation swaps the axes with them.
      magick -size 20x74 gradient:'#7aa2f7-#f28fad' -rotate -90 \
        \( -size 74x20 xc:none -fill white -draw 'roundrectangle 0,0 73,19 7,7' -alpha extract \) \
        -alpha off -compose copy_opacity -composite build/badge-bg.png
      magick build/badge-bg.png \
        \( -background none -fill '#0c1420' -font ${font} -pointsize 10 -kerning 2 label:"$1" \) \
        -gravity center -compose over -composite "build/badge-$2.png"
    }

    lockup() {
      magick -background none build/mark.png build/spacer.png build/divider.png \
        build/spacer.png build/wordmark.png build/spacer.png "build/badge-$1.png" \
        -gravity center +append "build/lockup-$1.png"
    }

    ${lib.concatMapStringsSep "\n    " (
      b: "badge ${b} ${lib.toLower b}\n    lockup ${lib.toLower b}"
    ) badges}

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out

    # Only the finished sprites ship; the intermediates above would bloat the
    # initrd, which Plymouth's theme is copied wholesale into.
    cp build/background.png build/lockup-*.png $out/

    runHook postInstall
  '';

  meta.description = "Shared Saturn background and lockup, baked for the boot stages";
}
