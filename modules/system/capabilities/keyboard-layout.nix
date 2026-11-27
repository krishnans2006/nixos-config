{ config, lib, root, ... }:

with lib;

let
  cfg = config.modules.keyboard-layout;
in
{
  options.modules.keyboard-layout = {
    enable = mkEnableOption "Enable the system-wide Kanata keyboard layout";
  };

  config = mkIf cfg.enable {
    services.kanata = {
      enable = true;
      keyboards.main.configFile = "${root + "/data/keyboard-layout.kbd"}";
    };
  };
}
