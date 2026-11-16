{ config, lib, osConfig, pkgs, root, ... }:

with lib;

let
  cfg = config.modules.dolphin-emu;

  verify-system = import (root + "/utils/verify-system.nix") {
    inherit lib osConfig;
    option = "modules.dolphin-emu.enable";
    type = "optional";
    reason = "to open the firewall port for Dolphin NetPlay";
  };
in
{
  options.modules.dolphin-emu = {
    enable = mkEnableOption "Install Dolphin Emulator";
  };

  config = mkIf cfg.enable (
    verify-system.apply {
      home.packages = [ pkgs.dolphin-emu ];

      # Settings/controller profiles, saves/NAND/save states, and game library.
      modules.impermanence.persistDirs = [
        ".config/dolphin-emu"
        ".local/share/dolphin-emu"
        "Games"
      ];
    }
  );
}
