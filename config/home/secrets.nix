{ config, pkgs, lib, ... }:

with lib;

let
  # Sops runs sops-install-secrets before impermanence creates a bind mount
  # So when sops runs under impermanence, /home/krishnan/.config/sops/age/keys.txt
  # will not be available, even if persisted in environment.persistence
  # Therefore we have to pull the key from /persist directly
  useImpermanence = config.environment.persistence ? "/persist";
in
{
  sops = {
    age.keyFile = "${optionalString useImpermanence "/persist"}/home/krishnan/.config/sops/age/keys.txt";
    defaultSopsFile = ../../secrets/home.yaml;
    defaultSopsFormat = "yaml";

    secrets = {
      "wakatime/wakatime" = {};  # Unused
      "wakatime/wakapi".path = "/home/krishnan/.wakatime.cfg";
      "wakatime/hackatime" = {};  # Unused

      "atuin/key" = {};  # Unused
      "atuin/key_b64" = {};

      "yubikey/u2f_keys".path = "/home/krishnan/.config/Yubico/u2f_keys";
    };
  };
}
