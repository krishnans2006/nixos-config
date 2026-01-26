{ config, pkgs, ... }:

{
  sops = {
    age.keyFile = "/home/krishnan/.config/sops/age/keys.txt";
    age.generateKey = false;  # Do it manually from an SSH key (see README.md)
    defaultSopsFile = ../../secrets/system.yaml;
    defaultSopsFormat = "yaml";

    secrets = {
      "networks" = {
        restartUnits = [ "NetworkManager.service" ];
      };

      # Adding paths to these secrets will require changes to the "networks" secret itself
      "openvpn/ovpn0/ca" = {
        restartUnits = [ "NetworkManager.service" ];
      };
      "openvpn/ovpn0/cert" = {
        restartUnits = [ "NetworkManager.service" ];
      };
      "openvpn/ovpn0/key" = {
        restartUnits = [ "NetworkManager.service" ];
      };
      "openvpn/ovpn0/ta" = {
        restartUnits = [ "NetworkManager.service" ];
      };
      # ovpn1 and ovpn2 share CA, cert, and key (under ovpn1-2)
      "openvpn/ovpn1/ca" = {
        key = "openvpn/ovpn1-2/ca";
        restartUnits = [ "NetworkManager.service" ];
      };
      "openvpn/ovpn1/cert" = {
        key = "openvpn/ovpn1-2/cert";
        restartUnits = [ "NetworkManager.service" ];
      };
      "openvpn/ovpn1/key" = {
        key = "openvpn/ovpn1-2/key";
        restartUnits = [ "NetworkManager.service" ];
      };
      "openvpn/ovpn2/ca" = {
        key = "openvpn/ovpn1-2/ca";
        restartUnits = [ "NetworkManager.service" ];
      };
      "openvpn/ovpn2/cert" = {
        key = "openvpn/ovpn1-2/cert";
        restartUnits = [ "NetworkManager.service" ];
      };
      "openvpn/ovpn2/key" = {
        key = "openvpn/ovpn1-2/key";
        restartUnits = [ "NetworkManager.service" ];
      };
    };
  };
}
