{ config, lib, ... }:

with lib;

let
  cfg = config.modules.eden-emu;
in
{
  options.modules.eden-emu = {
    enable = mkEnableOption "Eden Emulator system firewall configuration";
  };

  config = mkIf cfg.enable {
    # Eden multiplayer: https://github.com/eden-emulator/mirror/blob/master/docs/user/ServerHosting.md
    networking.firewall.allowedUDPPorts = [ 24872 ];
  };
}
