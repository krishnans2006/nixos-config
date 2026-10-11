{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.mt7921e;
in
{
  options.modules.mt7921e = {
    enable = mkEnableOption "MediaTek mt7921e Wi-Fi support";
  };

  # mt7921e firmware does not survive hibernation
  # so unload it before hibernating and reload it after resuming
  config = mkIf cfg.enable {
    powerManagement.powerDownCommands = ''
      ${pkgs.kmod}/bin/modprobe -r mt7921e || true
    '';
    powerManagement.resumeCommands = ''
      ${pkgs.kmod}/bin/modprobe mt7921e
    '';
  };
}
