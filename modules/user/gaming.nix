{ ... }:

# The overlay that answers "did this game actually land on the 4060?".
#
# Everything Steam launches carries the PRIME offload environment from
# modules/sys/gaming.nix, but nothing about the picture on screen tells you
# whether that worked — an Intel UHD renders most 2D-ish titles perfectly
# happily. gpu_name below is the cheapest check there is.
#
# Toggle it in-game with Shift+F12, or start a game with `mangohud %command%`
# in its launch options if it does not pick the layer up on its own.
{
  programs.mangohud = {
    enable = true;

    # Per-game, not an overlay stapled onto every GL/Vulkan app on the system.
    enableSessionWide = false;

    settings = {
      fps = true;
      frametime = false;
      gpu_name = true;
      gpu_temp = true;
      vram = true;
      cpu_temp = true;
      ram = true;
    };
  };
}
