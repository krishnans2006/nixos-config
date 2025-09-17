{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.modules.networks;

  makeOpenNetworkProfileConfig = id: autoconnect: {
    connection = {
      id = "$net${id}_name";
      type = "wifi";
      autoconnect = (if autoconnect then "true" else "false");
    };
    wifi = {
      mode = "infrastructure";
      ssid = "$net${id}_ssid";
    };
    ipv4 = {
      method = "auto";
      dns = "1.1.1.1;1.0.0.1;";
      ignore-auto-dns = "true";
    };
  };

  makePSKNetworkProfileConfig = id: autoconnect:
    (makeOpenNetworkProfileConfig id autoconnect) //
      {
        wifi-security = {
          key-mgmt = "wpa-psk";
          psk = "$net${id}_psk";
        };
      };

  makeEAPNetworkProfileConfig = id: autoconnect:
    (makeOpenNetworkProfileConfig id autoconnect) //
      {
        wifi-security = {
          key-mgmt = "wpa-eap";
        };
        "802-1x" = {
          eap = "$net${id}_eap";
          phase2-auth = "$net${id}_phase2_auth";
          identity = "$net${id}_identity";
          password = "$net${id}_password";
        };
      };

  makeWireguardVPNProfileConfig = id: {
    connection = {
      id = "$wg${id}_name";
      interface-name = "$wg${id}_interface";
      type = "wireguard";
    };
    wireguard = {
      private-key = "$wg${id}_key";
    };
    "wireguard-peer\.$wg${id}_peer" = {
      endpoint = "$wg${id}_endpoint";
      allowed-ips = "$wg${id}_allowed_ips";
    };
    ipv4 = {
      method = "manual";
      address1 = "$wg${id}_address";
      dns = "$wg${id}_dns_ips";
      dns-search = "$wg${id}_dns_names";
    };
    ipv6 = {
      method = "disabled";
      addr-gen-mode = "stable-privacy";
    };
  };

in
{
  imports = [
    ../config/secrets.nix
  ];

  options.modules.networks = {
    enable = mkEnableOption "Enable a customized NetworkManager with known networks and VPNs";
    ethernetOnly = mkOption {
      type = types.bool;
      default = false;
      description = "Disable autoconnect for WiFi networks";
    };
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
          networkmanager-openvpn
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

            net0 = (makePSKNetworkProfileConfig "0" (!cfg.ethernetOnly));
            net1 = (makePSKNetworkProfileConfig "1" (!cfg.ethernetOnly));
            net2 = (makeEAPNetworkProfileConfig "2" (!cfg.ethernetOnly));
            net3 = (makeEAPNetworkProfileConfig "3" (!cfg.ethernetOnly));
            net4 = (makePSKNetworkProfileConfig "4" (!cfg.ethernetOnly));
            net5 = (makePSKNetworkProfileConfig "5" (!cfg.ethernetOnly));
            net6 = (makePSKNetworkProfileConfig "6" (!cfg.ethernetOnly));
            net7 = (makePSKNetworkProfileConfig "7" (!cfg.ethernetOnly));
            net8 = (makePSKNetworkProfileConfig "8" (!cfg.ethernetOnly));
            net9 = (makePSKNetworkProfileConfig "9" (!cfg.ethernetOnly));
            net10 = (makeOpenNetworkProfileConfig "10" (!cfg.ethernetOnly));
            net11 = (makeOpenNetworkProfileConfig "11" (!cfg.ethernetOnly));

            wg0 = (makeWireguardVPNProfileConfig "0");
            wg1 = (makeWireguardVPNProfileConfig "1");

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
    };
  };
}
