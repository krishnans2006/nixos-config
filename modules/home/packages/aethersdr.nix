{ config, lib, osConfig, pkgs, root, ... }:

with lib;

let
  cfg = config.modules.aethersdr;

  aethersdr = pkgs.callPackage (root + "/custom/aethersdr.nix") { };

  verify-system = import (root + "/utils/verify-system.nix") {
    inherit lib osConfig;
    option = "modules.aethersdr.enable";
    type = "optional";
    reason = "to open firewall ports for AetherSDR and FlexRadio";
  };
in
{
  options.modules.aethersdr = {
    enable = mkEnableOption "Install AetherSDR";
  };

  config = mkIf cfg.enable (
    verify-system.apply {
      home.packages = [ aethersdr ];

      modules.impermanence.persistDirs = [ ".config/AetherSDR" ];
    }
  );
}
