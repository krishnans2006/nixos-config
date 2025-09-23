{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.tailscale;
in
{
  options.modules.tailscale = {
    enable = mkEnableOption "Enable Tailscale";
    enableTaildrive = mkEnableOption "Enable Tailscale Taildrive";
    taildrivePath = mkOption {
      type = types.str;
      default = "home/krishnan/Filesystems/Tailscale";
      description = "Path to mount Taildrive";
    };
  };

  config = mkIf cfg.enable (
    mkMerge [
      {
        services.tailscale.enable = true;
      }

      (mkIf cfg.enableTaildrive {
        services.davfs2 = {
          enable = true;
          davGroup = "davfs2";
        };
        users.users."krishnan".extraGroups = [ "davfs2" ];

        systemd.mounts = [
          {
            what = "http://100.100.100.100:8080";
            where = "${cfg.taildrivePath}";
            type = "davfs";
            
            wants = [ "tailscaled.service" ];
            after = [ "tailscaled.service" ];

            options = lib.concatStringsSep "," [ "noatime" "_netdev" "file_mode=0664" "dir_mode=2775" "user" "uid=${toString config.users.users."krishnan".uid}" "grpid" ];
          }
        ];
        systemd.automounts = [
          {
            wantedBy = [ "multi-user.target" ];
            where = "${cfg.taildrivePath}";
            automountConfig.TimeoutIdleSec = "30m";
          }
        ];

        environment.etc."davfs2/secrets" = {
          enable = true;
          text = "http://100.100.100.100:8080 \"\" \"\"";
          mode = "0600";
        };
      })
    ]
  );
}
