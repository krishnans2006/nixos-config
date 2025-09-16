{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.yubikey-auth;
in
{
  options.modules.yubikey-auth = {
    enable = mkEnableOption "Enable Yubikey authentication (U2F) for terminal login (see yubikey/u2f_keys in secrets-home)";
  };

  config = mkIf cfg.enable {
    security.pam.services = {
      login.u2fAuth = true;
      # sudo.u2fAuth = true;  # sudo is passwordless, so no need for U2F
    };
  };
}
