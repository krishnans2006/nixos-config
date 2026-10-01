{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.fs-mounts;
in
{
  options.modules.fs-mounts = {
    enable = mkEnableOption "Enable system-level NetworkManager dispatcher for SSHFS user mounts";
  };

  config = mkIf cfg.enable {
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
  };
}
