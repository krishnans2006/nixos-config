{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.iphone;
in
{
  options.modules.iphone = {
    enable = mkEnableOption "Enable support for connecting to iPhone via USB";
  };

  config = mkIf cfg.enable {
    services.usbmuxd.enable = true;

    environment.systemPackages = with pkgs; [
      libimobiledevice
      ifuse
    ];
  };
}
