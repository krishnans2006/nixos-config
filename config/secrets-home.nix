{ config, pkgs, ... }:

{
  sops = {
    age.keyFile = "/home/krishnan/.config/sops/age/keys.txt";
    defaultSopsFile = ../secrets/secrets-home.yaml;
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
