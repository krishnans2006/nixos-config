{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.fs-mounts;
in
{
  options.modules.fs-mounts = {
    enable = mkEnableOption "Enable system-level NetworkManager dispatcher for SSHFS user mounts";
    tjcsl = mkEnableOption "Enable system-level CephFS mount for TJ CSL filesystem";
  };

  config = mkMerge [
    (mkIf cfg.enable {
      networking.networkmanager.dispatcherScripts = [
        {
          source = pkgs.writeShellScript "fs-mounts-dispatcher" ''
            if [ "$2" = "up" ] || [ "$2" = "vpn-up" ]; then
              for u in /run/user/[0-9]*; do
                uid=$(basename "$u")
                if [ -d "$u/systemd" ]; then
                  ${pkgs.systemd}/bin/systemctl --machine="''${uid}@.host" --user start fs-mounts.target 2>/dev/null || true
                fi
              done
            fi
          '';
          type = "basic";
        }
      ];
    })

    (mkIf cfg.tjcsl (
      let
        tjcslCephConf = pkgs.writeText "tjcsl-ceph.conf" ''
          [global]
          mon_host = 198.38.17.88, 198.38.17.89, 198.38.17.84
        '';
      in
      {
        sops.secrets."fs-mounts/tjcsl" = { };

        system.fsPackages = [ pkgs.ceph ];

        fileSystems."/mnt/tjcsl" = {
          device = "198.38.17.88,198.38.17.89,198.38.17.84:/nfs/users/2024kshankar";
          fsType = "ceph";
          options = [
            "name=admin"
            "secretfile=${config.sops.secrets."fs-mounts/tjcsl".path}"
            "conf=${tjcslCephConf}"
            "noatime"
            "mount_timeout=5"
            "osdkeepalive=5"
            "recover_session=clean"
            "nowsync"
            "norbytes"
            "readdir_max_entries=4096"
            "readdir_max_bytes=1048576"
            "noauto"
            "x-systemd.automount"
            "x-systemd.idle-timeout=1min"
            "x-systemd.mount-timeout=5s"
            "x-systemd.show"
            "X-mount.idmap=u:33563571:1000:1 g:2024:100:1"  # Map 2024kshankar:tj24 to krishnan:users
            "_netdev"
          ];
        };
      }
    ))
  ];
}
