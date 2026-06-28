{ config, lib, ... }:

with lib;

let
  cfg = config.modules.localsend;
in
{
  options.modules.localsend = {
    enable = mkEnableOption "Enable localsend to send files over the local network";
  };

  config = mkIf cfg.enable {
    programs.localsend = {
      enable = true;
      openFirewall = true;
    };
  };
}
