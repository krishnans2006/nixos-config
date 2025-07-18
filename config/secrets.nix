{ config, pkgs, ... }:

{
  sops = {
    age.keyFile = "/home/krishnan/.config/sops/age/keys.txt";
    age.generateKey = false;  # Do it manually from an SSH key (see README.md)
    defaultSopsFile = ../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";

    secrets = {
      "wireguard/tjcsl" = {
        restartUnits = [ "wg-quick-tjcsl.service" ];
      };
      "wireguard/proton" = {
        restartUnits = [ "wg-quick-proton.service" ];
      };
      "wireguard/surfshark" = {
        restartUnits = [ "wg-quick-surfshark.service" ];
      };
      "networks" = {
        restartUnits = [ "NetworkManager.service" ];
      };
    };
  };
}
