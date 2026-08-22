{
  config,
  pkgs,
  ...
}:

# Graphics on the MSI Cyborg 15 A13VFK.
#
# This machine has two GPUs, and the one fact everything else in this file
# follows from is which of them owns which display output:
#
#   Intel UHD (Raptor Lake)   0000:00:02.0   ->  eDP-1 (laptop panel), HDMI-A-1
#   NVIDIA RTX 4060 Laptop    0000:01:00.0   ->  DP-1
#
# So the desktop runs entirely on the Intel GPU. That is not a compromise: it
# covers every display this laptop actually uses, and it lets the 4060 stay
# powered down. Confirm it is asleep with
#
#   cat /sys/bus/pci/devices/0000:01:00.0/power/runtime_status   # -> suspended
#
# The 4060 is on-demand hardware rather than idle hardware. Run a single
# program on it with `nvidia-offload <prog>`; CUDA and NVENC (DaVinci Resolve,
# ffmpeg, OBS) reach it directly without needing any of that.
#
# Known cost of this design: DP-1 is unreachable, because nothing here drives
# the NVIDIA card's outputs. Use HDMI for an external monitor.

let
  # The two GPUs, as the kernel and udev name them. Regenerate with:
  #   lspci -nn | grep -E 'VGA|3D'
  #   udevadm info -q property /dev/dri/card0 | grep ID_PATH=
  intelBusId = "PCI:0:2:0";
  nvidiaBusId = "PCI:1:0:0";

  # Same iGPU, in the form the udev rule at the bottom matches on.
  intelIdPath = "pci-0000:00:02.0";

  # Run a single program on the dGPU while the desktop stays on Intel:
  #   nvidia-offload glxinfo | grep vendor
  #   nvidia-offload steam
  #
  # This replaces the script that `prime.offload.enableOffloadCmd` would
  # install (which is why that option is set to false below). The stock one
  # points VK_ICD_FILENAMES at nvidia_icd.x86_64.json, copying the naming the
  # Mesa ICDs use — but NVIDIA ships the file without the .x86_64 infix, so
  # that path does not exist. Naming a nonexistent ICD file does not fall back
  # to scanning the default directory; it selects no Vulkan driver at all.
  nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __VK_LAYER_NV_optimus=NVIDIA_only
    export VK_DRIVER_FILES=/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.json
    exec "$@"
  '';
in
{
  # Despite the name, this is not about running an X server. It is how NixOS
  # decides to build and load the NVIDIA kernel modules and activate the
  # `hardware.nvidia` options below; the option name is historical.
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true; # required for Steam / Proton
    extraPackages = with pkgs; [
      intel-media-driver # VA-API on Raptor Lake
      vpl-gpu-rt # QuickSync
      nvidia-vaapi-driver
    ];
    extraPackages32 = with pkgs.pkgsi686Linux; [ intel-media-driver ];
  };

  hardware.nvidia = {
    # Ada is Turing+, so the open kernel modules are the supported path here.
    open = true;

    # Explicit sync landed in 555 and is what makes Wayland on NVIDIA stop
    # flickering and stuttering. Stay on a recent driver.
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    modesetting.enable = true; # mandatory for Wayland
    nvidiaSettings = true;

    # Lets the dGPU actually power down when nothing is offloaded onto it.
    # This is where the battery saving comes from, and it requires
    # prime.offload.enable below.
    powerManagement.enable = true;
    powerManagement.finegrained = true;

    prime = {
      inherit intelBusId nvidiaBusId;
      offload = {
        enable = true;
        # Off on purpose — the `nvidia-offload` defined above replaces it.
        # See the comment there before turning this back on.
        enableOffloadCmd = false;
      };
    };
  };

  environment.systemPackages = [
    nvidia-offload
    pkgs.nvtopPackages.intel
  ];

  # A colon-free stable name for the iGPU, consumed as AQ_DRM_DEVICES in
  # modules/user/hypr/session.nix.
  #
  # Aquamarine parses AQ_DRM_DEVICES as a *colon-separated* list, so the stock
  # /dev/dri/by-path/pci-0000:00:02.0-card symlink cannot be used there: the
  # colons inside the PCI address split it into three nonexistent paths, the DRM
  # backend finds no GPU and Hyprland aborts before it ever opens a display.
  # /dev/dri/cardN has no colons but its numbering is not stable across boots.
  #
  # Match on ID_PATH rather than KERNELS. KERNELS walks the whole parent chain,
  # which also matches the simpledrm boot framebuffer hanging off the same
  # Intel slot — that device is a card[0-9]* too, so it can race for this
  # symlink and win, leaving Hyprland pointed at a dumb framebuffer. ID_PATH is
  # an exact string, and simpledrm's is
  # "pci-0000:00:02.0-platform-simple-framebuffer.0", so it no longer matches.
  services.udev.extraRules = ''
    SUBSYSTEM=="drm", KERNEL=="card[0-9]*", ENV{ID_PATH}=="${intelIdPath}", SYMLINK+="dri/igpu"
  '';
}
