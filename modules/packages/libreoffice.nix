{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.modules.packages.libreoffice;
in
{
  options.modules.packages.libreoffice = {
    enable = mkEnableOption "Enable the LibreOffice suite";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      libreoffice-qt
      hunspell
      hunspellDicts.en_US
    ];
  };
}
