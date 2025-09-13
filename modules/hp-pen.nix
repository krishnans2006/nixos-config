{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.hp-pen;
in
{
  options.modules.hp-pen = {
    enable = mkEnableOption "Enable OpenTabletDriver for HP Pen support";
  };

  config = mkIf cfg.enable {
    hardware.opentabletdriver = {
      enable = true;
      daemon.enable = true;
    };
  };
}
