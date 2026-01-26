{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.printing;
in
{
  options.modules.printing = {
    enable = mkEnableOption "Enable printing and printer autodiscovery";
  };

  config = mkIf cfg.enable {
    # Enable CUPS to print documents.
    services.printing.enable = true;
    # Printer autodiscovery
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
  };
}
