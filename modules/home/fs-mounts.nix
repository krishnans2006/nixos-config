{ pkgs, config, lib, root, ... }:

with lib;

let
  cfg = config.modules.fs-mounts;

  mkSSHFSService = { description, what, where }:
    {
      Unit = {
        Description = description;
        Wants = [ "network-online.target" ];
        After = [ "network-online.target" ];
      };

      Service = {
        Type = "simple";
        ExecStartPre = escapeShellArgs [ "${pkgs.coreutils}/bin/mkdir" "-p" where ];
        ExecStart = escapeShellArgs [
          "${pkgs.sshfs}/bin/sshfs" what where
          "-f"
          "-o" "reconnect"
          "-o" "ServerAliveInterval=15"
          "-o" "ServerAliveCountMax=3"
          "-o" "IdentityFile=${config.sops.secrets."fs-key/private".path}"
          "-o" "StrictHostKeyChecking=no"
          "-o" "UserKnownHostsFile=/dev/null"
          "-o" "BatchMode=yes"
        ];
        ExecStop = escapeShellArgs [ "/run/wrappers/bin/fusermount" "-u" where ];
        Restart = "on-failure";
        RestartSec = "5";
      };

      Install = {
        WantedBy = [ "default.target" ];
      };
    };
in
{
  imports = [
    "${root}/config/home/secrets.nix"
  ];

  options.modules.fs-mounts = {
    tjcsl = mkEnableOption "Enable systemd user mounts for TJ CSL filesystem";
    ews = mkEnableOption "Enable systemd user mounts for UIUC EWS filesystem";
  };

  config = {
    home.packages = [ pkgs.sshfs ];

    systemd.user.services = mkMerge [
      (mkIf cfg.tjcsl {
        "mount-tjcsl" = mkSSHFSService {
          description = "SSHFS mount for TJ CSL filesystem";
          what = "2024kshankar@ras2.tjhsst.edu:/csl/users/2024kshankar";
          where = "/home/krishnan/Filesystems/tjCSL";
        };
      })

      # EWS server hangs during non-interactive SFTP/sshfs auth
      # (mkIf cfg.ews {
      #   "mount-ews" = mkSSHFSService {
      #     description = "SSHFS mount for UIUC EWS filesystem";
      #     what = "ks128@linux.ews.illinois.edu:/home/ks128";
      #     where = "/home/krishnan/Filesystems/EWS";
      #   };
      # })
    ];

    assertions = [
      {
        assertion = !cfg.ews;
        message = "EWS filesystem is broken";
      }
    ];
  };
}
