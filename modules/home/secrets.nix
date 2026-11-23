{ config, lib, pkgs, root, ... }:

with lib;

let
  cfg = config.modules.secrets;
  inherit (config.home) homeDirectory;

  # Sops runs sops-install-secrets before impermanence creates a bind mount
  # So when sops runs under impermanence, /home/krishnan/.config/sops/age/keys.txt
  # will not be available, even if persisted in environment.persistence
  # Therefore we have to pull the key from /persist directly
  useImpermanence = config.home.persistence."/persist".enable or false;
in
{
  options.modules.secrets = {
    enable = mkEnableOption "Enable home secrets";
    #
  };

  config = mkIf cfg.enable {
    sops = {
      age.keyFile = "${optionalString useImpermanence "/persist"}${homeDirectory}/.config/sops/age/keys.txt";
      defaultSopsFile = root + "/secrets/home.yaml";
      defaultSopsFormat = "yaml";

      age.sshKeyPaths = [ ];
      gnupg.sshKeyPaths = [ ];
    };

    home.packages = with pkgs; [
      sops
      age
      ssh-to-age
      #
    ];
  };
}
