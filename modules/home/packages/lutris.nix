{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.lutris;
in
{
  options.modules.lutris = {
    enable = mkEnableOption "Lutris";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.lutris-free ];

    # Impermanence
    modules.impermanence.persistDirs = [
      ".config/lutris"
      ".local/share/lutris"
      "Games"
      ".wine"
    ];
  };
}
