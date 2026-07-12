{ config, pkgs, lib, root, ... }:

with lib;

let
  # Sops runs sops-install-secrets before impermanence creates a bind mount
  # So when sops runs under impermanence, /home/krishnan/.config/sops/age/keys.txt
  # will not be available, even if persisted in environment.persistence
  # Therefore we have to pull the key from /persist directly
  useImpermanence = config.home.persistence."/persist".enable;
in
{
  sops = {
    age.keyFile = "${optionalString useImpermanence "/persist"}/home/krishnan/.config/sops/age/keys.txt";
    defaultSopsFile = "${root}/secrets/home.yaml";
    defaultSopsFormat = "yaml";

    age.sshKeyPaths = [];
    gnupg.sshKeyPaths = [];
  };

  home.packages = with pkgs; [
    sops
    age
    ssh-to-age
  ];
}
