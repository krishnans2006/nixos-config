{ config, lib, pkgs, root, ... }:

with lib;

let
  cfg = config.modules.packages.aethersdr;
  aetherSDR = pkgs.callPackage (root + "/custom/aethersdr.nix") { };
in
{
  options.modules.packages.aethersdr = {
    enable = mkEnableOption "Install AetherSDR";
  };

  config = mkIf cfg.enable {
    home.packages = [ aetherSDR ];

    modules.impermanence.persistDirs = [ ".config/AetherSDR" ];
  };
}
