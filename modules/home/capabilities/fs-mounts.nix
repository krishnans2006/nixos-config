{ pkgs, config, lib, ... }:

with lib;

let
  cfg = config.modules.fs-mounts;

  mkSSHFSService =
    { description, what, where }:
    {
      Unit = {
        Description = description;
        PartOf = [ "fs-mounts.target" ];
        Wants = [ "network-online.target" ];
        After = [ "network-online.target" ];
      };

      Service = {
        Type = "simple";
        ExecStartPre = escapeShellArgs [ "${pkgs.coreutils}/bin/mkdir" "-p" where ];
        ExecStart = escapeShellArgs [
          "${pkgs.sshfs}/bin/sshfs"
          what
          where
          "-f"
          "-o"
          "reconnect"
          "-o"
          "ConnectTimeout=5"
          "-o"
          "ServerAliveInterval=15"
          "-o"
          "ServerAliveCountMax=3"
          "-o"
          "StrictHostKeyChecking=no"
          "-o"
          "UserKnownHostsFile=/dev/null"
          "-o"
          "BatchMode=yes"
          "-o"
          "auto_unmount"
          "-o"
          "ssh_command=ssh -o RemoteCommand=none -o RequestTTY=no -o ConnectTimeout=5"
        ];
        ExecStop = escapeShellArgs [
          "/run/wrappers/bin/fusermount"
          "-u"
          "-z"
          where
        ];
        Restart = "no";
      };

      Install.WantedBy = [ "default.target" "fs-mounts.target" ];
    };
in
{
  options.modules.fs-mounts = {
    tjcsl = mkEnableOption "Enable systemd user mounts for TJ CSL filesystem";
    ews = mkEnableOption "Enable systemd user mounts for UIUC EWS filesystem";
    janux = mkEnableOption "Enable systemd user mounts for Janux filesystem";
  };

  config = mkIf (cfg.tjcsl || cfg.ews || cfg.janux) {
    home.packages = [ pkgs.sshfs ];

    systemd.user.targets.fs-mounts = {
      Unit = {
        Description = "Remote SSHFS mounts target";
        Wants = [ "network-online.target" ];
        After = [ "network-online.target" ];
      };
      Install.WantedBy = [ "default.target" ];
    };

    systemd.user.services = mkMerge [
      (mkIf cfg.tjcsl {
        "mount-tjcsl" = mkSSHFSService {
          description = "SSHFS mount for TJ CSL filesystem";
          what = "2024kshankar@ras2.tjhsst.edu:/csl/users/2024kshankar";
          where = "${config.home.homeDirectory}/Filesystems/tjcsl";
        };
      })

      (mkIf cfg.janux {
        "mount-janux" = mkSSHFSService {
          description = "SSHFS mount for Janux filesystem";
          what = "janux-spr5:/fast-lab-share/ks128";
          where = "${config.home.homeDirectory}/Filesystems/janux";
        };
      })

      (mkIf cfg.ews {
        "mount-ews" = mkSSHFSService {
          description = "SSHFS mount for UIUC EWS filesystem";
          what = "ews:/home/ks128";
          where = "${config.home.homeDirectory}/Filesystems/ews";
        };
      })
    ];
  };
}
