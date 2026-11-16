{ config, lib, osConfig, pkgs, root, ... }:

with lib;

let
  cfg = config.modules.eden-emu;

  verify-system = import (root + "/utils/verify-system.nix") {
    inherit lib osConfig;
    option = "modules.eden-emu.enable";
    type = "optional";
    reason = "to open the firewall port for Eden multiplayer";
  };
in
{
  options.modules.eden-emu = {
    enable = mkEnableOption "Install Eden Emulator";
  };

  config = mkIf cfg.enable (
    verify-system.apply {
      home.packages = [ pkgs.eden ];
    }
  );
}
