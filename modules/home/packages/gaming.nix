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

  config = mkMerge [
    (mkIf cfg.enableLutris {
      home.packages = [ pkgs.lutris-free ];

      # Impermanence
      modules.impermanence.persistDirs = [
        ".config/lutris"
        ".local/share/lutris"
        "Games"
        ".wine"
      ];
    })

    (mkIf cfg.enableMinecraft {
      home.packages = [ pkgs.prismlauncher ];

      # Impermanence
      modules.impermanence.persistDirs = [ ".local/share/PrismLauncher" ];
    })
  ];
}
