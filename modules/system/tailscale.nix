{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.tailscale;
in
{
  options.modules.tailscale = {
    enable = mkEnableOption "Enable Tailscale";
    enableNMIntegration = mkEnableOption "Enable Tailscale integration with NetworkManager";
    enableTaildrive = mkEnableOption "Enable Tailscale Taildrive";
    taildrivePath = mkOption {
      type = types.str;
      default = "home/krishnan/Filesystems/Tailscale";
      description = "Path to mount Taildrive";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      services.tailscale.enable = true;

      systemd.services.tailscaled.after = [ "wpa_supplicant.service" ];
    }

    (mkIf cfg.enableNMIntegration (
      let
        tailscale = "${config.services.tailscale.package}/bin/tailscale";

        nmConnectionName = "Tailscale";
        nmInterfaceName = "tailscale-nm";
        nmActive = "nmcli -t -f NAME,TYPE connection show --active | grep -Fxq '${nmConnectionName}:wireguard'";
        tailscaleActive = "tailscale status --json --peers=false --self=false 2>/dev/null | jq -e '.BackendState == \"Running\" or .BackendState == \"Starting\"' >/dev/null";
      in
      {
        # Plasma hides TUN connections, so represent Tailscale with an inert
        # WireGuard profile that it displays as a VPN. The key is intentionally
        # public: this profile has no peers, addresses, routes, or traffic.
        networking.networkmanager.ensureProfiles.profiles.tailscale-status = {
          connection = {
            id = nmConnectionName;
            type = "wireguard";
            interface-name = nmInterfaceName;
            autoconnect = "true";
          };
          wireguard.private-key = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
          ipv4.method = "disabled";
          ipv6.method = "disabled";
        };

        # When the "Connect" or "Disconnect" buttons are pressed in the GUI
        # Use the tailscale CLI to bring the Tailscale interface up or down
        networking.networkmanager.dispatcherScripts = [
          {
            source = pkgs.writeShellScript "tailscale-networkmanager-dispatcher" ''
              if [[ "$1" == '${nmInterfaceName}' && ("$2" == up || "$2" == down) ]]; then
                ${tailscale} "$2"
              fi
            '';
            type = "basic";
          }
        ];

        # Use a systemd service to detect changes in Tailscale status and bring
        # the NetworkManager profile up or down accordingly
        systemd.services.tailscale-networkmanager-status = {
          description = "Synchronize Tailscale status with NetworkManager";
          wantedBy = [ "multi-user.target" "NetworkManager.service" ];
          bindsTo = [ "NetworkManager.service" ];
          wants = [ "tailscaled.service" "NetworkManager-ensure-profiles.service" ];
          after = [ "tailscaled.service" "NetworkManager.service" "NetworkManager-ensure-profiles.service" ];
          path = [ config.networking.networkmanager.package config.services.tailscale.package pkgs.jq ];
          serviceConfig = {
            Restart = "always";
            RestartSec = 2;
          };

          script = ''
            previous=

            while true; do
              if ${tailscaleActive}; then
                current=up
              else
                current=down
              fi

              if [[ "$current" != "$previous" ]]; then
                if [[ "$current" == up ]] && ! ${nmActive}; then
                  nmcli connection up id '${nmConnectionName}'
                elif [[ "$current" == down ]] && ${nmActive}; then
                  nmcli connection down id '${nmConnectionName}'
                fi

                previous="$current"
              fi

              sleep 1
            done
          '';
        };
      }
    ))

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

          options = lib.concatStringsSep "," [
            "noatime"
            "_netdev"
            "file_mode=0664"
            "dir_mode=2775"
            "user"
            "uid=${toString config.users.users."krishnan".uid}"
            "grpid"
          ];
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
  ]);
}
