{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.waydroid;
in
{
  options.modules.waydroid = {
    enable = mkEnableOption "Enable waydroid (Android in a container)";
  };

  config = mkIf cfg.enable {
    virtualisation.waydroid.enable = true;
  };
}
