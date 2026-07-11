{ config, lib, pkgs, root, ... }:

with lib;

let
  cfg = config.modules.networks;

  baseNetworkOptions = {
    autoconnect = cfg.enableWifi;
  };

  mkOpenNetworkProfileConfig = id: options: {
    connection = {
      id = "$net${id}_name";
      type = "wifi";
      autoconnect = mkIf (options?autoconnect) (boolToString options.autoconnect);
      autoconnect-priority = mkIf (options?priority) (toString options.priority);
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

  mkPSKNetworkProfileConfig = id: options:
    (mkOpenNetworkProfileConfig id options) //
      {
        wifi-security = {
          key-mgmt = "wpa-psk";
          psk = "$net${id}_psk";
        };
      };

  mkEAPNetworkProfileConfig = id: options:
    (mkOpenNetworkProfileConfig id options) //
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

  # Options:
  # - autoconnect: boolean, whether to autoconnect on startup
  mkWireguardVPNProfileConfig = id: options: {
    connection = {
      id = "$wg${id}_name";
      interface-name = "$wg${id}_interface";
      type = "wireguard";
      autoconnect = mkIf (options?autoconnect) (boolToString options.autoconnect);
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

  # Using this function requires some secrets to be defined:
  # - openvpn/ovpn{id}/ca
  # - openvpn/ovpn{id}/cert
  # - openvpn/ovpn{id}/key
  # Options is an attrset of all booleans, intended to convey which options and secrets are set up
  # for the config ID, along with some tweaks to the config itself. Supported options:
  # - dns: Set custom DNS servers, requires "ovpn{id}_dns" option
  # - domains: Set custom search domains, requires "ovpn{id}_domains" option
  # - tcp: Use TCP instead of UDP
  # - ta: Use TLS Auth, requires "openvpn/ovpn{id}/ta" secret
  # - authSha256: Use SHA256 for auth (as opposed to SHA1)
  # - cipher: Specify a cipher, requires "ovpn{id}_cipher" option
  # - dataCiphers: Specify data ciphers and fallback, requires "ovpn{id}_data_ciphers" and "ovpn{id}_data_ciphers_fallback" options
  # - randomHostname: Use a random hostname for the remote
  # - dontReneg: Disable renegotiation
  # More options may be added when needed by new OpenVPN configurations
  mkOpenVPNProfileConfig = id: options: {
    connection = {
      id = "$ovpn${id}_name";
      type = "vpn";
    };
    vpn = {
      service-type = "org.freedesktop.NetworkManager.openvpn";
      connection-type = "tls";
      dev = "tun";
      proto-tcp = mkIf (options.tcp) "yes";

      remote = "$ovpn${id}_remote";
      remote-cert-tls = "server";
      verify-x509-name = "$ovpn${id}_verify_name";

      ca = config.sops.secrets."openvpn/ovpn${id}/ca".path;
      cert = config.sops.secrets."openvpn/ovpn${id}/cert".path;
      key = config.sops.secrets."openvpn/ovpn${id}/key".path;
      ta = mkIf (options.ta) config.sops.secrets."openvpn/ovpn${id}/ta".path;
      ta-dir = mkIf (options.ta) "1";

      cert-pass-flags = "0";
      challenge-response-flags = "0";

      auth = mkIf (options.authSha256) "SHA256";
      cipher = mkIf (options.cipher) "$ovpn${id}_cipher";
      data-ciphers = mkIf (options.dataCiphers) "$ovpn${id}_data_ciphers";
      data-ciphers-fallback = mkIf (options.dataCiphers) "$ovpn${id}_data_ciphers_fallback";

      remote-random-hostname = mkIf (options.randomHostname) "yes";
      reneg-seconds = mkIf (options.dontReneg) "0";
    };
    ipv4 = {
      method = "auto";
      never-default = "true";
      ignore-auto-dns = mkIf (options?dns) "true";
      dns = mkIf (options?dns) "$ovpn${id}_dns_ips";
      dns-search = mkIf (options?domains) "$ovpn${id}_dns_names";
    };
    ipv6 = {
      method = "disabled";
      addr-gen-mode = "stable-privacy";
    };
  };

  mkCiscoVPNProfileConfig = id: {
    connection = {
      id = "$cisco${id}_name";
      type = "vpn";
    };
    vpn = {
      service-type = "org.freedesktop.NetworkManager.openconnect";
      protocol = "anyconnect";

      gateway = "$cisco${id}_gateway";
      reported_os = "";
      stoken_source = "";

      cookie-flags = "2";
      gateway-flags = "2";
      gwcert-flags = "2";
      stoken_string-flags = "0";

      enable_csd_trojan = "no";
      pem_passphrase_fsid = "no";
      prevent_invalid_cert = "no";
    };
    vpn-secrets = {
      autoconnect = "yes";
      save_passwords = "no";
      save_plaintext_cookies = "no";
      "form:main:group_list" = "$cisco${id}_group";
      "form:main:username" = "$cisco${id}_username";
      "form:main:password" = "$cisco${id}_password";
      "form:main:secondary_password" = "$cisco${id}_2fa";  # "push", "sms", "otp", etc.
    };
    ipv4 = {
      method = "auto";
    };
    ipv6 = {
      method = "auto";
      addr-gen-mode = "default";
    };
  };

in
{
  imports = [
    "${root}/utils/secrets-system.nix"
  ];

  options.modules.networks = {
    enable = mkEnableOption "Enable a customized NetworkManager with known networks and VPNs";
    enableWifi = mkOption {
      type = types.bool;
      default = true;
      description = "Enable auto-connect for WiFi networks. If false, only Ethernet and VPNs will auto-connect.";
    };
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
      nameservers = [
        "1.1.1.1"
        "1.0.0.1"
      ];

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

            # WiFi
            # 5GHz (priority=5) is preferred over 2.4GHz (priority=2)

            # Home
            net0 = (mkPSKNetworkProfileConfig "0" (baseNetworkOptions // { priority = 5; }));
            net1 = (mkPSKNetworkProfileConfig "1" (baseNetworkOptions // { priority = 2; }));

            # School
            net2 = (mkEAPNetworkProfileConfig "2" (baseNetworkOptions // { priority = 5; }));
            net3 = (mkEAPNetworkProfileConfig "3" (baseNetworkOptions // { priority = 0; }));

            net4 = (mkPSKNetworkProfileConfig "4" (baseNetworkOptions // { priority = 5; }));
            net5 = (mkPSKNetworkProfileConfig "5" (baseNetworkOptions // { priority = 2; }));

            # Hotspot
            net6 = (mkPSKNetworkProfileConfig "6" (baseNetworkOptions // { priority = -1; }));

            net7 = (mkPSKNetworkProfileConfig "7" (baseNetworkOptions // { priority = 5; }));

            # Apartment
            net8 = (mkPSKNetworkProfileConfig "8" (baseNetworkOptions // { priority = 5; }));
            net9 = (mkPSKNetworkProfileConfig "9" (baseNetworkOptions // { priority = 2; }));
            net10 = (mkOpenNetworkProfileConfig "10" (baseNetworkOptions // { priority = 1; }));
            net11 = (mkOpenNetworkProfileConfig "11" (baseNetworkOptions // { priority = 0; }));

            # VPNs

            wg0 = (mkWireguardVPNProfileConfig "0" {
              autoconnect = true;
            });
            wg1 = (mkWireguardVPNProfileConfig "1" {
              autoconnect = false;
            });

            ovpn0 = (mkOpenVPNProfileConfig "0" {
              dns = true;
              domains = true;
              tcp = false;
              ta = true;
              authSha256 = true;
              cipher = false;
              dataCiphers = true;
              randomHostname = false;
              dontReneg = false;
            });
            ovpn1 = (mkOpenVPNProfileConfig "1" {
              tcp = true;
              ta = false;
              authSha256 = false;
              cipher = true;
              dataCiphers = false;
              randomHostname = true;
              dontReneg = true;
            });
            ovpn2 = (mkOpenVPNProfileConfig "2" {
              tcp = false;
              ta = false;
              authSha256 = false;
              cipher = true;
              dataCiphers = false;
              randomHostname = true;
              dontReneg = true;
            });

            cisco0 = (mkCiscoVPNProfileConfig "0");
          };
        };
      };
    };

    # Set up all needed network secrets
    sops.secrets = let
      base = {
        restartUnits = [ "NetworkManager.service" ];
      };
      sharedOpenVPN = key: name: (base // {
        key = "openvpn/${key}/${name}";
      });
    in
    {
      "networks" = base;

      "openvpn/ovpn0/ca" = base;
      "openvpn/ovpn0/cert" = base;
      "openvpn/ovpn0/key" = base;
      "openvpn/ovpn0/ta" = base;

      # ovpn1 and ovpn2 share CA, cert, and key (under ovpn1-2)
      "openvpn/ovpn1/ca" = sharedOpenVPN "ovpn1-2" "ca";
      "openvpn/ovpn1/cert" = sharedOpenVPN "ovpn1-2" "cert";
      "openvpn/ovpn1/key" = sharedOpenVPN "ovpn1-2" "key";
      "openvpn/ovpn2/ca" = sharedOpenVPN "ovpn1-2" "ca";
      "openvpn/ovpn2/cert" = sharedOpenVPN "ovpn1-2" "cert";
      "openvpn/ovpn2/key" = sharedOpenVPN "ovpn1-2" "key";
    };
  };
}
