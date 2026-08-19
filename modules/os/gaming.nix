{ pkgs, ... }:

{
  programs.steam = {
    enable = true;

    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = false;
    localNetworkGameTransfers.openFirewall = true;

    gamescopeSession.enable = true; # Useful for scalling and fullscreen on Wayland

    extraCompatPackages = [ pkgs.proton-ge-bin ];
  };

  programs.gamescope = {
    enable = true;
    capSysNice = true; # allows realtime priority
  };

  # Performance monitoring overlay
  # Usage: enable per game with `mangohud %command%` in Steam's launch options, or MANGOHUD=1 in the environment.
  environment.systemPackages = with pkgs; [
    mangohud
    protonup-qt
  ];

  # Steam's 32-bit stack and Proton both want a generous file descriptor limit; the default trips some titles.
  security.pam.loginLimits = [
    {
      domain = "*";
      type = "hard";
      item = "nofile";
      value = "524288";
    }
  ];

  # Shader compilation and Proton prefixes chew through /tmp.
  boot.tmp.cleanOnBoot = true;
}
