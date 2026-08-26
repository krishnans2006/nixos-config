{ config, lib, ... }:

with lib;

let
  cfg = config.modules.wake-on-lan;
in
{
  options.modules.wake-on-lan = {
    enable = mkEnableOption "Enable wake-on-lan support";
    interfaces = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "List of network interfaces to enable wake-on-lan on";
    };
  };

  config = mkIf cfg.enable {
    networking = {
      firewall.allowedUDPPorts = [ 9 ];  # WOL uses UDP port 9

      interfaces = genAttrs (cfg.interfaces) (i: { wakeOnLan.enable = true; });
    };
  };
}
