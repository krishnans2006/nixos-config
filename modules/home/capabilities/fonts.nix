{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.fonts;
in
{
  options.modules.fonts = {
    enable = mkEnableOption "Enable font management and install some basic fonts";
    #
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ corefonts vista-fonts ];

    fonts.fontconfig.enable = true;
  };
}
