{ config, lib, pkgs, root, ... }:

with lib;

let
  cfg = config.modules.secrets;

  # Sops runs sops-install-secrets before impermanence creates a bind mount
  # So when sops runs under impermanence, /home/krishnan/.config/sops/age/keys.txt
  # will not be available, even if persisted in environment.persistence
  # Therefore we have to pull the key from /persist directly
  useImpermanence = config.home.persistence."/persist".enable;
in
{
  options.modules.secrets = {
    enable = mkEnableOption "Enable home secrets";
    #
  };

  config = mkIf cfg.enable {
    sops = {
      age.keyFile = "${optionalString useImpermanence "/persist"}/home/krishnan/.config/sops/age/keys.txt";
      defaultSopsFile = "${root}/secrets/home.yaml";
      defaultSopsFormat = "yaml";

      age.sshKeyPaths = [ ];
      gnupg.sshKeyPaths = [ ];

      secrets = {
        # Yubikey auth (see modules/system/yubikey-auth.nix)
        "yubikey/u2f_keys".path = "/home/krishnan/.config/Yubico/u2f_keys";

        # WakaTime config (pick one to use)
        "wakatime/wakatime" = { };  # Unused
        "wakatime/wakapi".path = "/home/krishnan/.wakatime.cfg";
        "wakatime/hackatime" = { };  # Unused
      };
    };

    home.packages = with pkgs; [
      sops
      age
      ssh-to-age
      #
    ];
  };
}
