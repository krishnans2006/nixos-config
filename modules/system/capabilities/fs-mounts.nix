{ config, lib, ... }:

with lib;

let
  cfg = config.modules.fs-mounts;

  mkSSHFSMount = device: {
    inherit device;
    fsType = "fuse.sshfs";
    options = [
      "x-systemd.automount"
      "noauto"
      "x-systemd.idle-timeout=600"
      "_netdev"
      "nofail"
      "allow_other"
      "reconnect"
      "ServerAliveInterval=15"
      "ServerAliveCountMax=3"
      "StrictHostKeyChecking=no"
      "UserKnownHostsFile=/dev/null"
    ];
  };
in
{
  options.modules.fs-mounts = {
    tjcsl = mkEnableOption "Enable mounts for TJ CSL filesystem";
    ews = mkEnableOption "Enable mounts for UIUC EWS filesystem";
  };

  config = mkMerge [
    (mkIf cfg.tjcsl {
      fileSystems."/mnt/tjcsl" = mkSSHFSMount "2024kshankar@ras2.tjhsst.edu:/csl/users/2024kshankar";
    })

    (mkIf cfg.ews {
      fileSystems."/mnt/ews" = mkSSHFSMount "ks128@linux.ews.illinois.edu:/home/ks128";
    })

    {
      assertions = [
        {
          assertion = !cfg.ews;
          message = "EWS filesystem is broken";
        }
      ];
    }
  ];
}
