{ pkgs, ... }:

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
  environment.systemPackages = with pkgs; [
    davinci-resolve
  ];
}
