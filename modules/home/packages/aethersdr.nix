{ config, lib, osConfig, pkgs, root, ... }:

with lib;

let
  cfg = config.modules.packages.aethersdr;
  osCfg = osConfig.modules.aethersdr;

  aethersdr = pkgs.callPackage (root + "/custom/aethersdr.nix") { };
in
{
  options.modules.packages.aethersdr = {
    enable = mkEnableOption "Install AetherSDR";
  };

  # Must be enabled in system config
  config = mkIf cfg.enable (
    mkAssert osCfg.enable "modules.aethersdr is not enabled in system config" {
      home.packages = [ aethersdr ];

      modules.impermanence.persistDirs = [ ".config/AetherSDR" ];
    }
  );
}
