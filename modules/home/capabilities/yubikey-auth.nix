{ config, lib, osConfig, root, ... }:

with lib;

let
  cfg = config.modules.yubikey-auth;
  inherit (config.home) homeDirectory;

  verify-system = import (root + "/utils/verify-system.nix") {
    inherit lib osConfig;
    option = "modules.yubikey-auth.enable";
    type = "required";
    reason = "requires system-level PAM U2F authentication";
  };
in
{
  options.modules.yubikey-auth = {
    enable = mkEnableOption "Install the YubiKey U2F authentication secret";
  };

  # Must be enabled in system config
  config = mkIf cfg.enable (
    verify-system.apply {
      sops.secrets."yubikey/u2f_keys".path = "${homeDirectory}/.config/Yubico/u2f_keys";
    }
  );
}
