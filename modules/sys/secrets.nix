{ config, pkgs, ... }:

{
  sops = {
    defaultSopsFile = ../../secrets.yaml;
    validateSopsFiles = false; # the file need not exist until you create one

    age = {
      keyFile = "/var/lib/sops-nix/key.txt";
      generateKey = false;
      sshKeyPaths = [ ];
    };

    secrets."ssh_private_key" = {
      owner = "hcabel";
      path = "/home/hcabel/.ssh/id_ed25519";
      mode = "0600";
    };

    secrets."gpg_private_key" = {
      owner = "hcabel";
      mode = "0400";
    };
  };

  systemd.user.services.import-gpg-key = {
    description = "Import the sops-managed GPG private key";
    wantedBy = [ "default.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.gnupg}/bin/gpg --batch --import ${config.sops.secrets."gpg_private_key".path}";
    };
  };

  environment.systemPackages = with pkgs; [
    gnupg
    sops
    age
    ssh-to-age
  ];

  services.openssh = {
    enable = true;
    openFirewall = false;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };
}
