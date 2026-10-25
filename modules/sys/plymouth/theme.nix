{
  lib,
  stdenvNoCC,
  imagemagick,
  resvg,
  wallpaper,
  font,
}:

# Every pixel this theme draws is baked here rather than at boot, because the
# Plymouth script plugin can do far less than the greeter's QML can: sprites
# carry a single scalar opacity with no gradient primitive, there is no blur,
# and only one font weight survives into the initrd (boot.plymouth.font copies
# exactly one file). So anything with a gradient, a rounded corner, letter
# spacing or a bold weight is rendered ahead of time and the script only moves
# the results around.
#
# The composition is authored at 1920x1080 to match Style.designWidth/Height in
# the shell; saturn.script scales from that to whatever mode the panel is in.

stdenvNoCC.mkDerivation {
  pname = "plymouth-theme-saturn";
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
    # The scrim is composited in here because a sprite cannot hold a gradient.
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
    badge BOOT boot
    badge UNLOCK unlock

    lockup() {
      magick -background none build/mark.png build/spacer.png build/divider.png \
        build/spacer.png build/wordmark.png build/spacer.png "build/badge-$1.png" \
        -gravity center +append "build/lockup-$1.png"
    }
    lockup boot
    lockup unlock

    # --- status header --------------------------------------------------
    # Static and pre-rendered: the script plugin's string type has no case
    # conversion, so uppercase letterspaced text cannot be produced at runtime.
    # The live systemd unit names go in the log list below instead.
    magick -background none -fill '#faf3e6' -font ${font} -pointsize 12 \
      -kerning 5 label:'SYSTEM STARTING' build/header.png
    magick -background none -fill '#faf3e6' -font ${font} -pointsize 12 \
      -kerning 5 label:'DISK LOCKED' build/header-auth.png

    # --- progress bar ---------------------------------------------------
    magick -size 520x2 xc:'#211f2e' build/progress-track.png
    magick -size 2x520 gradient:'#7aa2f7-#f28fad' -rotate -90 build/progress-fill.png
    magick \
      \( -size 2x90 gradient:'gray(0%)-gray(55%)' -rotate -90 \) \
      \( -size 2x90 gradient:'gray(55%)-gray(0%)' -rotate -90 \) \
      +append -alpha off build/sheen-mask.png
    magick -size 180x2 xc:white build/sheen-mask.png \
      -alpha off -compose copy_opacity -composite build/sheen.png

    # --- password dialog ------------------------------------------------
    magick -size 660x56 xc:none -fill '#1b1930' \
      -draw 'roundrectangle 0,0 659,55 18,18' build/field.png
    magick -size 8x8 xc:none -fill '#faf3e6' -draw 'circle 4,4 4,0' build/bullet.png
    magick -size 2x19 xc:'#f28fad' build/caret.png
    magick -background none -fill '#99938a' -font ${font} -pointsize 11 \
      label:'return to unlock' build/hint.png
    magick -background none -fill '#f7768e' -font ${font} -pointsize 11 \
      label:'caps lock is on' build/caps.png

    # --- spinner --------------------------------------------------------
    # 36 pre-rotated frames. Image.Rotate() exists but re-rasterises on every
    # call, and this runs at the refresh rate.
    resvg assets/ring.svg -w 84 -h 84 build/ring.png
    for i in $(seq 0 35); do
      magick build/ring.png -background none -distort SRT "$((i * 10))" \
        +repage -gravity center -extent 84x84 "build/ring-$i.png"
    done

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    d=$out/share/plymouth/themes/saturn
    mkdir -p "$d"

    # Only the finished sprites ship; the intermediates above would bloat the
    # initrd, which is copied wholesale into it.
    cp build/background.png build/lockup-*.png build/header*.png \
       build/progress-*.png build/sheen.png build/field.png build/bullet.png \
       build/caret.png build/hint.png build/caps.png build/ring-*.png "$d/"

    cp saturn.script "$d/saturn.script"
    substitute saturn.plymouth.in "$d/saturn.plymouth" --subst-var-by themedir "$d"

    runHook postInstall
  '';

  meta.description = "Saturn boot splash, matching the greeter and the bar";
}
