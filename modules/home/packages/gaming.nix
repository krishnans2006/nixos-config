{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.gaming;
in
{
  options.modules.gaming = {
    enableLutris = mkEnableOption "Lutris";
    enableMinecraft = mkEnableOption "Minecraft via Prism Launcher";
  };

  config = {
    home.packages = mkMerge [
      (mkIf cfg.enableLutris [
        pkgs.lutris-free
        #
      ])

      (mkIf cfg.enableMinecraft [
        pkgs.prismlauncher
        #
      ])
    ];
  };
}
