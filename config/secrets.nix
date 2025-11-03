{ config, pkgs, ... }:

{
  sops = {
    age.keyFile = "/home/krishnan/.config/sops/age/keys.txt";
    age.generateKey = false;  # Do it manually from an SSH key (see README.md)
    defaultSopsFile = ../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";

    secrets = {
      "networks" = {
        restartUnits = [ "NetworkManager.service" ];
      };
    };
  };
}
