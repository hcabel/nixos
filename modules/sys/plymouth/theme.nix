{
  lib,
  stdenvNoCC,
  imagemagick,
  resvg,
  sprites,
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

    # --- background and lockup ------------------------------------------
    # Baked in ../saturn-stage, because GRUB's menu draws the same two things
    # and the framebuffer carries straight over from it into this splash.
    cp ${sprites}/background.png ${sprites}/lockup-boot.png \
       ${sprites}/lockup-unlock.png build/

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
