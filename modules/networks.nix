{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.modules.networks;

  makeOpenNetworkProfileConfig = id: {
    connection.id = "$net${id}_name";
    connection.type = "wifi";
    wifi.mode = "infrastructure";
    wifi.ssid = "$net${id}_ssid";
    ipv4.method = "auto";
    ipv4.dns = "1.1.1.1;1.0.0.1;";
    ipv4.ignore-auto-dns = "true";
  };

  makePSKNetworkProfileConfig = id: {
    connection.id = "$net${id}_name";
    connection.type = "wifi";
    wifi.mode = "infrastructure";
    wifi.ssid = "$net${id}_ssid";
    wifi-security.key-mgmt = "wpa-psk";
    wifi-security.psk = "$net${id}_psk";
    ipv4.method = "auto";
    ipv4.dns = "1.1.1.1;1.0.0.1;";
    ipv4.ignore-auto-dns = "true";
  };

  makeEAPNetworkProfileConfig = id: {
    connection.id = "$net${id}_name";
    connection.type = "wifi";
    wifi.mode = "infrastructure";
    wifi.ssid = "$net${id}_ssid";
    wifi-security.key-mgmt = "wpa-eap";
    "802-1x".eap = "$net${id}_eap";
    "802-1x".phase2-auth = "$net${id}_phase2_auth";
    "802-1x".identity = "$net${id}_identity";
    "802-1x".password = "$net${id}_password";
    ipv4.method = "auto";
    ipv4.dns = "1.1.1.1;1.0.0.1;";
    ipv4.ignore-auto-dns = "true";
  };

in
{
  imports = [
    ../config/secrets.nix
  ];

  options.modules.networks = {
    enable = mkEnableOption "Enable a customized NetworkManager with known networks and VPNs";
  };

  config = mkIf cfg.enable {
    services.resolved = {
      enable = true;
      domains = [ "~." ];
      fallbackDns = [
        "1.1.1.1"
        "1.0.0.1"
      ];
      dnssec = "allow-downgrade";
      dnsovertls = "opportunistic"; # maybe "true" is possible?
    };

    networking = {
      nameservers = [
        "1.1.1.1"
        "1.0.0.1"
      ];

      wireless.enable = false;

      networkmanager = {
        enable = true;
        dns = "systemd-resolved";
        wifi.backend = "wpa_supplicant";

        plugins = with pkgs; [
          networkmanager-openconnect
        ];

        ensureProfiles = {
          environmentFiles = [ config.sops.secrets."networks".path ];

          profiles = {
            ethernet = {
              connection.type = "ethernet";
              connection.id = "Ethernet";
              ipv4.method = "auto";
              ipv4.dns = "1.1.1.1;1.0.0.1;";
              ipv4.ignore-auto-dns = "true";
            };

            net0 = (makePSKNetworkProfileConfig "0");
            net1 = (makePSKNetworkProfileConfig "1");
            net2 = (makeEAPNetworkProfileConfig "2");
            net3 = (makeEAPNetworkProfileConfig "3");
            net4 = (makePSKNetworkProfileConfig "4");
            net5 = (makePSKNetworkProfileConfig "5");
            net6 = (makePSKNetworkProfileConfig "6");
            net7 = (makePSKNetworkProfileConfig "7");
            net8 = (makePSKNetworkProfileConfig "8");
            net9 = (makePSKNetworkProfileConfig "9");
            net10 = (makeOpenNetworkProfileConfig "10");
            net11 = (makeOpenNetworkProfileConfig "11");

            uiucvpn = {
              connection.id = "UIUC";
              connection.type = "vpn";

              vpn.cookie-flags = "2";
              vpn.enable_csd_trojan = "no";
              vpn.gateway = "vpn.illinois.edu";
              vpn.gateway-flags = "2";
              vpn.gwcert-flags = "2";
              vpn.pem_passphrase_fsid = "no";
              vpn.prevent_invalid_cert = "no";
              vpn.protocol = "anyconnect";
              vpn.reported_os = "";
              vpn.stoken_source = "";
              vpn.stoken_string-flags = "0";
              vpn.service-type = "org.freedesktop.NetworkManager.openconnect";

              vpn-secrets.autoconnect = "yes";
              vpn-secrets.save_passwords = "yes";
              vpn-secrets.save_plaintext_cookies = "no";
              vpn-secrets."form:main:group_list" = "DuoSplitTunnel";
              vpn-secrets."form:main:username" = "ks128";

              ipv4.method = "auto";
              ipv6.method = "auto";
              ipv6.addr-gen-mode = "default";
            };
          };
        };
      };

      wg-quick.interfaces = {
        tjcsl = {
          autostart = true;
          configFile = config.sops.secrets."wireguard/tjcsl".path;
        };
        proton = {
          autostart = false;
          configFile = config.sops.secrets."wireguard/proton".path;
        };
        surfshark = {
          autostart = false;
          configFile = config.sops.secrets."wireguard/surfshark".path;
        };
      };
    };
  };
}
