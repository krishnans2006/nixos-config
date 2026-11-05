{ config, lib, ... }:

with lib;

let
  cfg = config.modules.firefox;

  settings = import (root + "/data/firefox-settings.nix") { home = config.home.homeDirectory; };
in
{
  options.modules.firefox = {
    enable = mkEnableOption "Enable Firefox web browser";
    #
  };

  config = mkIf cfg.enable {
    programs.firefox = {
      enable = true;
      configPath = "${config.xdg.configHome}/mozilla/firefox";

      profiles.default = {
        id = 0;
        name = "default";
        isDefault = true;
        settings = settings;
      };
    };
  };
}
