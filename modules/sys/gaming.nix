{ lib, pkgs, ... }:

# Steam on a machine whose desktop deliberately does not touch the dGPU.
#
# hosts/msi-laptop/gpu.nix runs the whole session on the Intel iGPU — it owns
# eDP-1 and HDMI-A-1 — and leaves the 4060 behind prime.offload. Nothing
# reaches the NVIDIA card unless it asks to, so a bare
# `programs.steam.enable = true` would run every game on the Intel UHD.
#
# So the offload environment is baked into the Steam package itself rather than
# typed into each game's launch options: the client exports it, and every game
# the client spawns inherits it.
#
# There is no longer a power cost to leaving Steam open: gpu.nix disables runtime
# D3 outright, so the 4060 stays powered whether or not anything is using it.
let
  # Same variables `nvidia-offload` exports in hosts/msi-laptop/gpu.nix, with
  # one difference that matters.
  nvidiaOffload = {
    __NV_PRIME_RENDER_OFFLOAD = "1";
    __NV_PRIME_RENDER_OFFLOAD_PROVIDER = "NVIDIA-G0";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    __VK_LAYER_NV_optimus = "NVIDIA_only";

    # Both architectures, unlike the single path in gpu.nix. nvidia_icd.json
    # hardcodes an *absolute* library_path into the 64-bit driver's store path,
    # so a 32-bit Vulkan loader cannot use the 64-bit file. The Steam client
    # binary is 32-bit and Proton runs 32-bit Wine components, and naming only
    # the 64-bit ICD would leave all of them with no Vulkan driver at all —
    # the same failure mode gpu.nix documents for the stock offload script.
    # The loader walks this list and skips entries whose library won't load.
    VK_DRIVER_FILES = lib.concatStringsSep ":" [
      "/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.json"
      "/run/opengl-driver-32/share/vulkan/icd.d/nvidia_icd.json"
    ];
  };
in
{
  programs.steam = {
    enable = true;

    # extraEnv composes with the module's own: it merges what it needs
    # (STEAM_EXTRA_COMPAT_TOOLS_PATHS for the compat packages below) with
    # whatever the override already set.
    package = pkgs.steam.override { extraEnv = nvidiaOffload; };

    # Steam runs inside an FHS sandbox, so these have to be *inside* it to be
    # reachable as `mangohud %command%` / `gamemoderun %command%` launch options.
    extraPackages = with pkgs; [
      mangohud
      gamemode
    ];

    # Community Proton build: extra media codecs and per-game fixes that
    # upstream Proton ships without. Picked per game in the compatibility tab.
    extraCompatPackages = [ pkgs.proton-ge-bin ];
    protontricks.enable = true;

    remotePlay.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;

    # Registers share/wayland-sessions/steam.desktop, which the greeter picks
    # up on its own (modules/sys/greeter/default.nix scans that directory), so
    # Big Picture shows up as a session chip at login.
    gamescopeSession.enable = true;
  };

  programs.gamescope = {
    enable = true;

    # Off on purpose, and it has to stay off.
    #
    # With it on, the module stops installing gamescope into systemPackages and
    # registers `security.wrappers.gamescope` instead, so the only gamescope on
    # PATH is /run/wrappers/bin/gamescope. That wrapper (wrapper.c in nixpkgs)
    # unconditionally unsets every glibc "unsecure" variable — LD_LIBRARY_PATH,
    # LD_PRELOAD, LD_AUDIT — before exec'ing the real binary, whether or not any
    # privilege was actually gained. Steam's launch chain
    # (steam-launch-wrapper -> reaper -> SteamLinuxRuntime -> proton) is built
    # around exactly those two variables, so `gamescope -- %command%` in a
    # game's launch options dies before the game ever starts. Renaming does not
    # help either: the Steam FHS exports PATH=/run/wrappers/bin:/usr/bin:...,
    # so a second uncapped gamescope would just be shadowed.
    #
    # What this gives up is gamescope reniceing itself and `--rt`. gamemode
    # below has enableRenice, and that is what actually prioritises the game.
    capSysNice = false;

    # Without this the nested compositor itself would come up on the iGPU and
    # drag every game it hosts along with it.
    env = nvidiaOffload;
  };

  programs.gamemode = {
    enable = true;
    enableRenice = true;
  };
}
