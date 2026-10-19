{ config, lib, osConfig, root, ... }:

with lib;

let
  cfg = config.modules.tailscale;

  verify-system = import (root + "/utils/verify-system.nix") {
    inherit lib osConfig;
    option = "modules.tailscale.enable";
    type = "required";
    reason = "requires system-level Tailscale service";
  };
in
{
  options.modules.tailscale = {
    enable = mkEnableOption "Enable Tailscale";
    #
  };

  # Must be enabled in system config
  config = mkIf cfg.enable (
    verify-system.apply {
      programs.ssh.settings = {
        "pc" = {
          HostName = "krishnan-pc.emperor-snares.ts.net";
          User = "krishnan";
        };
        "laptop" = {
          HostName = "krishnan-lap.emperor-snares.ts.net";
          User = "krishnan";
        };
        "vivo" = {
          HostName = "krishnan-vivo.emperor-snares.ts.net";
          User = "krishnan";
        };
        "pi" = {
          HostName = "krishnan-pi.emperor-snares.ts.net";
          User = "krishnan";
        };
        "phi" = {
          HostName = "krishnan-phi.emperor-snares.ts.net";
          User = "krishnan";
        };
      };
    }
  );
}
