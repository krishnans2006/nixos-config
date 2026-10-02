{ config, lib, pkgs, ... }:

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
          networkmanager-openconnect
          networkmanager-openvpn
        ];
      };
    };
  };
}
