{ config, lib, osConfig, ... }:

with lib;

let
  cfg = config.modules.tailscale;
  osCfg = osConfig.modules.tailscale;
in
{
  options.modules.tailscale = {
    enable = mkEnableOption "Enable Tailscale";
  };

  # Must be enabled in system config
  config = mkIf cfg.enable ( mkAssert osCfg.enable "modules.tailscale is not enabled in system config" {
    programs.ssh.matchBlocks = {
      "pc" = {
        hostname = "krishnan-pc.emperor-snares.ts.net";
        user = "krishnan";
      };
      "laptop" = {
        hostname = "krishnan-lap.emperor-snares.ts.net";
        user = "krishnan";
      };
    };
  });
}
