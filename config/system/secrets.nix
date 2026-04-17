{ config, lib, root, ... }:

with lib;

let
  # Sops runs sops-install-secrets before impermanence creates a bind mount
  # So when sops runs under impermanence, /home/krishnan/.config/sops/age/keys.txt
  # will not be available, even if persisted in environment.persistence
  # Therefore we have to pull the key from /persist directly
  useImpermanence = config.environment.persistence."/persist".enable ? "/persist";
in
{
  sops = {
    age.keyFile = "${optionalString useImpermanence "/persist"}/home/krishnan/.config/sops/age/keys.txt";
    age.generateKey = false;  # Do it manually from an SSH key (see README.md)
    defaultSopsFile = "${root}/secrets/system.yaml";
    defaultSopsFormat = "yaml";

    secrets = {
      "password" = {
        neededForUsers = true;
      };

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
