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

    (mkIf config.modules.ssh.enableAuthorizedKeys {
      assertions = [
        {
          assertion = osConfig == null || !(osConfig.modules.krishnan-user.enable && osConfig.modules.ssh-server.enable);
          message = "modules.ssh.enableAuthorizedKeys must be disabled when openssh server is enabled in system config";
        }
      ];

      # SELinux-confined sshd cannot follow a Nix store symlink
      home.activation.installAuthorizedKeys = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        install -d -m 0700 ${escapeShellArg "${config.home.homeDirectory}/.ssh"}
        rm -f ${escapeShellArg "${config.home.homeDirectory}/.ssh/authorized_keys"}
        install -m 0600 ${../../dotfiles/authorized_keys} ${escapeShellArg "${config.home.homeDirectory}/.ssh/authorized_keys"}
      '';
    })
  ]);
}
