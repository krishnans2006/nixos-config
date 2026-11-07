{ config, osConfig, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.gaming;

  verify-system = import (root + "/utils/verify-system.nix") {
    inherit lib osConfig;
    option = "modules.gaming.enable";
    type = "optional";
  };
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

    (mkIf verify-system.satisfied {
      # If Steam is installed at the system level, then we can set up user-level impermanence
      # If it's not, that's okay; no need for warnings/errors (so we don't use .apply)
      modules.impermanence.persistDirs = [ ".steam" ".local/share/Steam" ];
    })
  ];
}
