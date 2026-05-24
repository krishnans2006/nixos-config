{ pkgs, config, lib, root, ... }:

with lib;

let
  cfg = config.modules.fs-mounts;
  sshfsOptions = [
    "-o" "noatime"
    "-o" "allow_other"
    "-o" "reconnect"
    "-o" "ServerAliveInterval=15"
    "-o" "ServerAliveCountMax=3"
    "-o" "IdentityFile=${config.sops.secrets."fs-key/private".path}"
    "-o" "StrictHostKeyChecking=no"
    "-o" "UserKnownHostsFile=/dev/null"
  ];
in
{
  imports = [
    "${root}/config/system/secrets.nix"
  ];

  options.modules.fs-mounts = {
    tjcsl = mkEnableOption "Enable systemd mounts for TJ CSL filesystem";
    ews = mkEnableOption "Enable systemd mounts for UIUC EWS filesystem";
  };

  config = {
    environment.systemPackages = with pkgs; [
      sshfs
    ];

    programs.fuse.userAllowOther = true;

    users.groups.fuse = { };
    users.users."krishnan".extraGroups = [ "fuse" ];

    systemd.services = mkMerge [
      (mkIf cfg.tjcsl {
        systemd.services."mount-tjcsl" = {
          description = "SSHFS mount for TJ CSL filesystem";
          wantedBy = [ "multi-user.target" ];
          wants = [ "network-online.target" ];
          after = [ "network-online.target" ];

          serviceConfig = {
            Type = "simple";
            ExecStart = lib.concatStringsSep " " ([
              "${pkgs.sshfs}/bin/sshfs"
              "2024kshankar@ras2.tjhsst.edu:/csl/users/2024kshankar"
              "/home/krishnan/Filesystems/tjCSL"
              "-f"
            ] ++ sshfsOptions);
            ExecStop = "/run/wrappers/bin/fusermount -u /home/krishnan/Filesystems/tjCSL";
            Restart = "on-failure";
            RestartSec = "5";
            ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p /home/krishnan/Filesystems/tjCSL";
          };
        };
      })

      (mkIf cfg.ews {
        systemd.services."mount-ews" = {
          description = "SSHFS mount for UIUC EWS filesystem";
          wantedBy = [ "multi-user.target" ];
          wants = [ "network-online.target" ];
          after = [ "network-online.target" ];

          serviceConfig = {
            Type = "simple";
            ExecStart = lib.concatStringsSep " " ([
              "${pkgs.sshfs}/bin/sshfs"
              "ks128@linux.ews.illinois.edu:/home/ks128"
              "/home/krishnan/Filesystems/EWS"
              "-f"
            ] ++ sshfsOptions);
            ExecStop = "/run/wrappers/bin/fusermount -u /home/krishnan/Filesystems/EWS";
            Restart = "on-failure";
            RestartSec = "5";
            ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p /home/krishnan/Filesystems/EWS";
          };
        };
      })
    ];
  };
}
