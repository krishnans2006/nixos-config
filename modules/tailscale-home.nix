{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.tailscale;
in
{
  options.modules.tailscale = {
    enable = mkEnableOption "Enable Tailscale";
  };

  config = mkIf cfg.enable {
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
  };
}
