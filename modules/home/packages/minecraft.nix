{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.minecraft;
in
{
  options.modules.minecraft = {
    enable = mkEnableOption "Minecraft via Prism Launcher";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.prismlauncher ];

    # Impermanence
    modules.impermanence.persistDirs = [ ".local/share/PrismLauncher" ];
  };
}
