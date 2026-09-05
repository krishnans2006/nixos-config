{ config, lib, root, ... }:

with lib;

let
  cfg = config.modules.networks;

  # Network profile helpers
  inherit (import "${root}/utils/networks.nix" { inherit lib config; })
    mkOpenNetworkProfileConfig
    mkPSKNetworkProfileConfig
    mkEAPNetworkProfileConfig
    mkWireguardVPNProfileConfig
    mkOpenVPNProfileConfig
    mkCiscoVPNProfileConfig
    ;
in
{
  options.modules.networks = {
    enable = mkEnableOption "Enable known networks and VPNs through NetworkManager profiles";
    enableWifi = mkOption {
      type = types.bool;
      default = true;
      description = "Enable auto-connect for WiFi networks. If false, only Ethernet and VPNs will auto-connect.";
    };
  };

  config = mkIf cfg.enable {
    modules.secrets.enable = mkForce true;

    networking.networkmanager.ensureProfiles = {
      environmentFiles = [ config.sops.secrets."networks".path ];

      profiles =
        let
          baseNetworkOptions = {
            autoconnect = cfg.enableWifi;
            #
          };
        in
        {
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

          wg0 = (mkWireguardVPNProfileConfig "0" { autoconnect = true; });
          wg1 = (mkWireguardVPNProfileConfig "1" { autoconnect = false; });

          ovpn0 = (
            mkOpenVPNProfileConfig "0" {
              dns = true;
              domains = true;
              tcp = false;
              ta = true;
              authSha256 = true;
              cipher = false;
              dataCiphers = true;
              randomHostname = false;
              dontReneg = false;
            }
          );
          ovpn1 = (
            mkOpenVPNProfileConfig "1" {
              tcp = true;
              ta = false;
              authSha256 = false;
              cipher = true;
              dataCiphers = false;
              randomHostname = true;
              dontReneg = true;
            }
          );
          ovpn2 = (
            mkOpenVPNProfileConfig "2" {
              tcp = false;
              ta = false;
              authSha256 = false;
              cipher = true;
              dataCiphers = false;
              randomHostname = true;
              dontReneg = true;
            }
          );

          cisco0 = (mkCiscoVPNProfileConfig "0");
        };
    };

    # Set up all needed network secrets
    sops.secrets =
      let
        base = {
          restartUnits = [ "NetworkManager.service" ];
        };
        sharedOpenVPN = key: name: (base // { key = "openvpn/${key}/${name}"; });
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
