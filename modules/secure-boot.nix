{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.secure-boot;
in
{
  options.modules.secure-boot = {
    enable = mkEnableOption "Enable UEFI Secure Boot using lanzaboote";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.sbctl ];

    # Lanzaboote currently replaces the systemd-boot module. This setting is usually set to true in
    # configuration.nix generated at installation time. So we force it to false for now.
    boot.loader.systemd-boot.enable = lib.mkForce false;

    boot.lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
    };
  };
}
