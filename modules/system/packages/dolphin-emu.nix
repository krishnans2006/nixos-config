{ config, lib, ... }:

with lib;

let
  cfg = config.modules.dolphin-emu;
in
{
  options.modules.dolphin-emu = {
    enable = mkEnableOption "Dolphin Emulator system firewall configuration";
  };

  config = mkIf cfg.enable {
    # Dolphin NetPlay
    networking.firewall.allowedUDPPorts = [ 2626 ];
  };
}
