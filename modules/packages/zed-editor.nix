{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.packages.zed-editor;
in
{
  options.modules.packages.zed-editor = {
    enable = mkEnableOption "Install Zed code editor";
  };

  config = mkIf cfg.enable {
    programs.zed-editor = {
      enable = true;

      userSettings = {
        telemetry = {
          metrics = false;
        };
      };
    };
  };
}
