{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.bluetooth;
in
{
  options.modules.bluetooth = {
    enable = mkEnableOption "Enable Bluetooth";
  };

  config = mkIf cfg.enable {
    hardware.bluetooth.enable = true;  # Enable Bluetooth
    hardware.bluetooth.powerOnBoot = true;  # Power the default Bluetooth controller on boot
    # A2DP
    hardware.bluetooth.settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
        FastConnectable = "true";
        MultiProfile = "multiple";
        Experimental = true;
      };
    };
    #services.blueman.enable = true;
  };
}
