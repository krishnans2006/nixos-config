{ config, lib, ... }:

with lib;

let
  cfg = config.modules.networking;
in
{
  options.modules.networking = {
    enable = mkEnableOption "Enable a customized NetworkManager config";
    #
  };

  config = mkIf cfg.enable {
    services.resolved = {
      enable = true;
      settings.Resolve = {
        Domains = [ "~." ];
        FallbackDNS = [ "1.1.1.1" "1.0.0.1" ];
        DNSSEC = "allow-downgrade";
        DNSOverTLS = "opportunistic";  # maybe "true" is possible?
      };
    };

    networking = {
      nameservers = [ "1.1.1.1" "1.0.0.1" ];

      networkmanager = {
        enable = true;
        dns = "systemd-resolved";
        wifi.backend = "wpa_supplicant";

        plugins = with pkgs; [
          # Enabled by default, just here to be explicit
          networkmanager-fortisslvpn
          networkmanager-iodine
          networkmanager-l2tp
          networkmanager-openconnect
          networkmanager-openvpn
          networkmanager-vpnc
          networkmanager-sstp
        ];
      };
    };
  };
}
