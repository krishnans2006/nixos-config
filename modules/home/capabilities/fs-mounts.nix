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

      # The idea here is to fail very quickly
      # If the initial connection doesn't succeed within 5 seconds, we fail
      # If we get disconnected for 5 * 3 = 15 seconds, we fail
      # There are two ways to "bring it back up":
      # - Run `systemctl --user start fs-mounts.target`
      # - Trigger the NetworkManager dispatcher script in modules/system/capabilities/fs-mounts.nix
      #   by connecting to a VPN or network
      # This is all so that the filesystem rarely hangs waiting for the connection
      Service = {
        Type = "simple";
        ExecStartPre = escapeShellArgs [ "${pkgs.coreutils}/bin/mkdir" "-p" where ];
        ExecStart = escapeShellArgs [
          "${pkgs.sshfs}/bin/sshfs"
          what
          where
          "-f"
          "-o"
          "ConnectTimeout=5"
          "-o"
          "ServerAliveInterval=5"
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
    ews = mkEnableOption "Enable systemd user mounts for UIUC EWS filesystem";
    janux = mkEnableOption "Enable systemd user mounts for Janux filesystem";
  };

  config = mkIf (cfg.ews || cfg.janux) {
    home.packages = [ pkgs.sshfs ];

    systemd.user.targets.fs-mounts = {
      Unit = {
        Description = "Remote mounts target";
        Wants = [ "network-online.target" ];
        After = [ "network-online.target" ];
      };
      Install.WantedBy = [ "default.target" ];
    };

    systemd.user.services = mkMerge [
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
