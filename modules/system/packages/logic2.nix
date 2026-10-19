{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.logic2;
in
{
  options.modules.logic2 = {
    enable = mkEnableOption "Install Saleae Logic 2";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.saleae-logic-2 ];

    # Udev rules
    hardware.saleae-logic.enable = true;
  };
}
