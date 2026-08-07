{ config, lib, ... }:

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

        systemd.services.tailscaled.after = [ "wpa_supplicant.service" ];

        # Plasma hides TUN connections, so expose a harmless dummy connection
        # whose lifetime follows tailscaled without letting NetworkManager
        # manage the real tailscale0 interface.
        systemd.services.tailscale-networkmanager-status = mkIf config.networking.networkmanager.enable {
          description = "Expose Tailscale status to NetworkManager";
          wantedBy = [ "tailscaled.service" "NetworkManager.service" ];
          bindsTo = [ "tailscaled.service" "NetworkManager.service" ];
          after = [ "tailscaled.service" "NetworkManager.service" ];
          path = [ config.networking.networkmanager.package ];

          script = ''
            nmcli connection delete id Tailscale 2>/dev/null || true
            nmcli connection add save no \
              type dummy \
              con-name Tailscale \
              ifname tailscale-nm \
              connection.autoconnect no \
              ipv4.method disabled \
              ipv6.method disabled
            nmcli connection up id Tailscale
          '';

          preStop = ''
            nmcli connection delete id Tailscale 2>/dev/null || true
          '';

          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            Restart = "on-failure";
            RestartSec = 2;
          };
        };
      }

      (mkIf cfg.enableTaildrive {
        services.davfs2 = {
          enable = true;
          davGroup = "davfs2";
        };
        users.users."krishnan".extraGroups = [ "davfs2" ];

        systemd.mounts = [
          {
            # what = "http://100.100.100.100:8080/krishnans2006%%40gmail.com";  # %40 = @
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
