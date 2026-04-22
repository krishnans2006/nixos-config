{ config, lib, ... }:

with lib;

let
  cfg = config.modules.direnv;
in
{
  options.modules.direnv = {
    enable = mkEnableOption "Enable nix-direnv for project-specific environments";
  };

  config = mkIf cfg.enable {
    programs.direnv = {
      enable = true;
      #enableBashIntegration = true;
      nix-direnv.enable = true;
      config = {
        global."warn_timeout" = 0;
      };
    };
  };
}
