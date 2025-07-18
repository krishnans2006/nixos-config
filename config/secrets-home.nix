{ config, pkgs, ... }:

{
  sops = {
    age.keyFile = "/home/krishnan/.config/sops/age/keys.txt";
    defaultSopsFile = ../secrets/secrets-home.yaml;
    defaultSopsFormat = "yaml";

    secrets = {
      "wakatime/wakatime" = {};
      "wakatime/wakapi".path = "/home/krishnan/.wakatime.cfg";
      "wakatime/hackatime" = {};

      "atuin/key" = {};
      "atuin/key_b64" = {};

      "yubikey/u2f_keys".path = "/home/krishnan/.config/Yubico/u2f_keys";
    };
  };
}
