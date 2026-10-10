{ config, lib, ... }:

with lib;

let
  cfg = config.modules.aethersdr;
  pkgCfg = config.modules.packages.aethersdr;
  enabled = cfg.enable || pkgCfg.enable;
in
{
  options.modules = {
    aethersdr = {
      enable = mkEnableOption "AetherSDR and FlexRadio system firewall configuration";
      openFirewall = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to open firewall ports for AetherSDR and FlexRadio";
      };
    };
    packages.aethersdr = {
      enable = mkEnableOption "AetherSDR and FlexRadio system firewall configuration";
      openFirewall = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to open firewall ports for AetherSDR and FlexRadio";
      };
    };
  };

  config = mkIf (enabled && cfg.openFirewall && pkgCfg.openFirewall) {
    networking.firewall = {
      # FlexRadio & AetherSDR network ports:
      # UDP 4992: FlexRadio discovery broadcast
      # UDP 4991: VITA-49 data streams (panadapter, waterfall, audio, DAX IQ)
      # UDP 4993: SmartLink VITA-49 data tunnel (WAN/remote)
      # UDP 9007: 4O3A Antenna Genius discovery broadcast
      # TCP 4992: SmartSDR command and control API
      # TCP 4994: SmartLink command and control tunnel (WAN/remote)
      # TCP 4532: Hamlib rigctld CAT server
      # TCP 50001-50004: TCI (Transceiver Control Interface) server
      allowedUDPPorts = [ 4991 4992 4993 9007 ];
      # AetherSDR dynamically binds a local UDP socket on port 0 for VITA-49 spectrum
      # streaming and announces it to the radio with "client udpport <port>". On Linux,
      # port 0 allocates from the ephemeral port range (32768-60999).
      allowedUDPPortRanges = [
        {
          from = 32768;
          to = 60999;
        }
      ];
      allowedTCPPorts = [ 4532 4992 4994 ];
      allowedTCPPortRanges = [
        {
          from = 50001;
          to = 50004;
        }
      ];
    };
  };
}
