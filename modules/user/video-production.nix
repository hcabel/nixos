{ pkgs, ... }:

# Free DaVinci Resolve on Linux ships no H.264/H.265 decoder and no AAC
# decoder — those are Studio-only. Camera .mov files (HEVC + AAC) therefore
# import with broken audio and unreliable video. Transcode to DNxHR first;
# Resolve reads that natively.
#
#   resolve-transcode clip.mov            # DNxHR SQ, edit quality
#   resolve-transcode -p lb clip.mov      # DNxHR LB, proxy quality
#
# Rough sizes for 4K 24p, per minute of footage: LB ~1 GB, SQ ~3.3 GB,
# HQ ~5.3 GB. Decode runs on the 4060 via NVDEC, so it lands around 0.6x
# realtime.
let
  # Resolve's viewer hands OpenGL textures to CUDA. That interop only works when
  # both contexts live on the same physical GPU, and under GNOME Wayland it does
  # not: CUDA lands on the 4060 while the GL context stays on the Intel iGPU.
  # Resolve logs this as
  #   GPU.MultiBoardMgr | WARN | OpenGL context is not running on the GPU
  #                              marked as Main Display GPU.
  # then fails every frame with cudaErrorUnknown, which it misreports to the UI
  # as "out of GPU memory".
  #
  # Forcing GL onto the NVIDIA card puts both contexts back on one device. The
  # Qt vars matter as much as the NVIDIA ones — Resolve has to go through
  # XWayland/GLX for the offload vars to apply at all.
  davinci-resolve-nvidia = pkgs.symlinkJoin {
    name = "davinci-resolve-nvidia";
    paths = [ pkgs.davinci-resolve ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      rm $out/bin/davinci-resolve
      makeWrapper ${pkgs.davinci-resolve}/bin/davinci-resolve $out/bin/davinci-resolve \
        --set QT_QPA_PLATFORM xcb \
        --set QT_XCB_GL_INTEGRATION glx \
        --set __NV_PRIME_RENDER_OFFLOAD 1 \
        --set __NV_PRIME_RENDER_OFFLOAD_PROVIDER NVIDIA-G0 \
        --set __GLX_VENDOR_LIBRARY_NAME nvidia \
        --set __VK_LAYER_NV_optimus NVIDIA_only \
        --set __EGL_VENDOR_LIBRARY_FILENAMES /run/opengl-driver/share/glvnd/egl_vendor.d/10_nvidia.json \
        --set VK_DRIVER_FILES /run/opengl-driver/share/vulkan/icd.d/nvidia_icd.json \
        --set OCL_ICD_VENDORS /run/opengl-driver/etc/OpenCL/vendors
    '';
  };

  resolve-transcode = pkgs.writeShellApplication {
    name = "resolve-transcode";
    runtimeInputs = [ pkgs.ffmpeg ];
    text = ''
      profile=sq

      while getopts ":p:" opt; do
        case "$opt" in
          p) profile="$OPTARG" ;;
          *) echo "usage: resolve-transcode [-p lb|sq|hq] FILE..." >&2; exit 2 ;;
        esac
      done
      shift $((OPTIND - 1))

      case "$profile" in
        lb | sq | hq) ;;
        *) echo "unknown profile '$profile' (expected lb, sq or hq)" >&2; exit 2 ;;
      esac

      if [ $# -eq 0 ]; then
        echo "usage: resolve-transcode [-p lb|sq|hq] FILE..." >&2
        exit 2
      fi

      for src in "$@"; do
        dst="''${src%.*}_dnxhr_$profile.mov"
        echo "==> $src -> $dst"
        ffmpeg -nostdin -hide_banner -loglevel warning -stats \
          -hwaccel cuda -i "$src" \
          -map 0:v -map 0:a? \
          -c:v dnxhd -profile:v "dnxhr_$profile" -pix_fmt yuv422p \
          -c:a pcm_s16le \
          "$dst"
      done
    '';
  };
in
{
  # Video/Stream recorder
  programs.obs-studio = {
    enable = true;

    package = (
      pkgs.obs-studio.override {
        cudaSupport = true;
      }
    );

    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-pipewire-audio-capture
      obs-backgroundremoval
      obs-vaapi
    ];
  };

  # Video editor
  home.packages = with pkgs; [
    davinci-resolve-nvidia
    ffmpeg
    resolve-transcode
  ];
}
