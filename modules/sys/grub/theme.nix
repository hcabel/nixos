{
  lib,
  stdenvNoCC,
  imagemagick,
  grub2,
  sprites,
  font,
}:

# The generation menu, themed to match the splash that follows it. Everything
# that is not a solid colour is baked here, for the same reason Plymouth bakes
# its sprites and then some: GRUB has no letter-spacing, and its pixmap styles
# are nine-sliced with a repeating centre tile, so they cannot carry a gradient
# either. The two shared pieces — the scrimmed wallpaper and the lockup — come
# from ../saturn-stage so this and the splash cannot drift apart.
#
# theme.txt holds the layout and the reasoning behind it.

stdenvNoCC.mkDerivation {
  pname = "grub-theme-saturn";
  version = "1";

  src = lib.cleanSource ./.;

  nativeBuildInputs = [
    imagemagick
    grub2
  ];

  buildPhase = ''
    runHook preBuild
    mkdir -p build

    # --- fonts ----------------------------------------------------------
    # install-grub.pl emits a `loadfont` line for every .pf2 it finds in the
    # theme directory, so shipping them here is all that is needed.
    #
    # grub-mkfont stores the name as "<family> <weight> <size>" and GRUB looks
    # fonts up by exact string match, which is why theme.txt asks for
    # "Saturn Regular 16" rather than the family alone.
    mkfont() {
      grub-mkfont -n Saturn -s "$1" -o "build/saturn-$1.pf2" ${font}
    }
    mkfont 12 # timeout counter
    mkfont 14 # the terminal behind `c` and `e`
    mkfont 16 # menu entries

    # --- header ---------------------------------------------------------
    # Same recipe as Plymouth's SYSTEM STARTING / DISK LOCKED headers, so the
    # three read as one family.
    #
    # Every PNG below is written through PNG32: — eight-bit RGBA, no palette.
    # GRUB's PNG reader handles nothing else: a sixteen-bit image decodes to
    # garbage and an indexed one silently loses its alpha, so ImageMagick's
    # habit of picking the most compact encoding has to be overridden every
    # time. The one exception is background.png, which arrives from
    # ../saturn-stage already eight-bit and opaque.
    magick -background none -fill '#faf3e6' -font ${font} -pointsize 12 \
      -kerning 5 label:'SELECT GENERATION' PNG32:build/header.png

    # --- nine-slice boxes -----------------------------------------------
    # GRUB builds a box from nine tiles: the four corners at their natural
    # size, the four edges stretched along one axis, the centre along both.
    # `slice` cuts a square source into that set. ImageMagick numbers the crops
    # row-major, which is the order named below.
    slice() {
      local src="$1" name="$2" n="$3"
      magick "$src" -crop "''${n}x''${n}" +repage "PNG32:build/piece-%d.png"
      local i=0
      for pos in nw n ne w c e sw s se; do
        mv "build/piece-$i.png" "build/$name-$pos.png"
        i=$((i + 1))
      done
    }

    # The selected row: a flat band of Style.surfaceCard (#18162C at 0.58, hence
    # alpha 94) with a 2px Style.accent rule down its left edge.
    #
    # Square rather than rounded, and the tile size is the whole reason. A slice
    # size is also the box's padding on every side, and the padding sits outside
    # the row it marks — so a corner radius worth of it made the highlight stand
    # 26px taller than its own text and balloon into view as the selection
    # arrived. At 2px that overhang is invisible. It also buys back the accent
    # rule, which a large radius made impossible: the west tile is the only
    # place it can live, and only at this size is that tile the full height of
    # the row rather than a stub between two curves.
    #
    # Cropped into 2x2, the left-hand column of tiles (nw/w/sw) is pure accent
    # and the west one stretches vertically into a continuous rule, while
    # n/c/s/e/ne/se carry the wash. 2 here is tied to item_spacing and to the
    # menu's left/top in theme.txt; changing it means changing those with it.
    magick -size 6x6 xc:'#18162C94' -fill '#7aa2f7' \
      -draw 'rectangle 0,0 1,5' PNG32:build/select-src.png
    slice build/select-src.png select 2

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    d=$out/share/grub/themes/saturn
    mkdir -p "$d"

    cp ${sprites}/background.png "$d/background.png"
    # Sixteen-bit as it comes out of the shared sprite build, which Plymouth is
    # happy with and GRUB decodes as noise. Flattened to eight-bit RGBA here
    # rather than upstream so the splash keeps the file it already had.
    magick ${sprites}/lockup-boot.png -depth 8 PNG32:"$d/lockup.png"

    cp build/header.png "$d/"
    cp build/saturn-*.pf2 "$d/"
    # The glob catches select-src.png too; it is an intermediate, not a slice.
    cp build/select-*.png "$d/"
    rm -f "$d/select-src.png"

    cp theme.txt "$d/theme.txt"

    runHook postInstall
  '';

  meta.description = "Saturn GRUB theme, matching the boot splash and the greeter";
}
