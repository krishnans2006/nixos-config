{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.fs-mounts;
in
{
  options.modules.fs-mounts = {
    tjcsl = mkEnableOption "Enable systemd mounts for TJ CSL filesystem";
    ews = mkEnableOption "Enable systemd mounts for UIUC EWS filesystem";
  };

  config = {
    systemd.mounts = lib.optionals cfg.tjcsl [
      {
        what = "2024kshankar@ras2.tjhsst.edu:/csl/users/2024kshankar";
        where = "/home/krishnan/Filesystems/tjCSL";
        type = "fuse.sshfs";

        options = lib.concatStringsSep "," [ "_netdev" "noatime" "IdentityFile=/home/krishnan/.ssh/id_ed25519" ];
      }
    ] ++ lib.optionals cfg.ews [
      {
        what = "ks128@linux.ews.illinois.edu:/home/ks128";
        where = "/home/krishnan/Filesystems/EWS";
        type = "fuse.sshfs";

        options = lib.concatStringsSep "," [ "_netdev" "noatime" "IdentityFile=/home/krishnan/.ssh/id_ed25519" ];
      }
    ];

    systemd.automounts = lib.optionals cfg.tjcsl [
      {
        wantedBy = [ "multi-user.target" ];
        where = "/home/krishnan/Filesystems/tjCSL";
        automountConfig.TimeoutIdleSec = "30m";
      }
    ] ++ lib.optionals cfg.ews [
      {
        wantedBy = [ "multi-user.target" ];
        where = "/home/krishnan/Filesystems/EWS";
        automountConfig.TimeoutIdleSec = "30m";
      }
    ];
  };
}
