{ config, lib, osConfig ? null, ... }:

with lib;

let
  cfg = config.modules.ssh;
in
{
  options.modules.ssh = {
    enable = mkEnableOption "Enable custom SSH client configuration and known hosts";
    enableAuthorizedKeys = mkEnableOption "Install authorized SSH keys on non-NixOS systems";
  };

  config = mkIf cfg.enable (mkMerge [
    {
      programs.ssh = {
        enable = true;
        enableDefaultConfig = false;

        settings = {
          "*" = {
            AddKeysToAgent = "yes";
            # ControlMaster = "auto";
            # ControlPath = "~/.ssh/master-%r@%h:%p";
            # ControlPersist = "3s";
          };
          "ews" = {
            HostName = "linux.ews.illinois.edu";
            IdentityFile = "~/.ssh/id_ed25519";
            User = "ks128";
            ForwardX11 = true;
            ForwardX11Trusted = true;
            RequestTTY = "yes";
            RemoteCommand = "/bin/zsh";
          };
          "ews-391" = {
            HostName = "eceb-3026.ews.illinois.edu";
            IdentityFile = "~/.ssh/id_ed25519";
            User = "ks128";
            ForwardX11 = true;
            ForwardX11Trusted = true;
            RequestTTY = "yes";
            RemoteCommand = "/bin/zsh";
          };
          "ncsa-delta" = {
            HostName = "login.delta.ncsa.illinois.edu";
            User = "krishnans2006";
            ForwardX11 = true;
          };
          "oracle-amp" = {
            HostName = "150.136.13.65";
            IdentityFile = "~/.ssh/id_ed25519";
            User = "ubuntu";
          };
          "oracle-vm1" = {
            HostName = "150.136.122.56";
            IdentityFile = "~/.ssh/id_ed25519";
            User = "ubuntu";
          };
          "oracle-vm2" = {
            HostName = "129.153.27.23";
            IdentityFile = "~/.ssh/id_ed25519";
            User = "ubuntu";
          };
          "piserver.local" = {
            HostName = "piserver.local";
            User = "krishnan";
          };
          "tjfridge" = {
            HostName = "fridge.tjhsst.edu";  # 198.38.23.53
            User = "kshankar";
          };
          "tjras" = {
            HostName = "ras2.tjhsst.edu";  # 198.38.18.201
            User = "2024kshankar";
          };
        };
      };
    }

    (mkIf cfg.enableAuthorizedKeys {
      assertions = [
        {
          assertion = (
            osConfig == null || !(osConfig.modules.krishnan-user.enable && osConfig.modules.ssh-server.enable)
          );
          message = "modules.ssh.enableAuthorizedKeys must be disabled when openssh server is enabled in system config";
        }
      ];

      home.file.".ssh/authorized_keys".text = (concatStringsSep "\n" [
        # krishnan-pc
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPzvD6itrqgr9qqNVao8XnuRX3dLH9rUTf9xMydB9VG3 krishnans2006@gmail.com"
        # krishnan-lap
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ37RZ3TIIuDNS3wcaQ4t0z5NkT1H4GukVcke3GNOn40 krishnans2006@gmail.com"
        # krishnan-vivo
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEjk4Ah+IsWbXjwpA89sL1s01UdJoobtFlpeBxcHJkTj krishnans2006@gmail.com"
        # krishnan-pi
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDZgsLeuVcdgehuhwpO8ZZuzPzTQhPGjYcrnzLSBCCP2 krishnans2006@gmail.com"
      ]) + "\n";
    })
  ]);
}
