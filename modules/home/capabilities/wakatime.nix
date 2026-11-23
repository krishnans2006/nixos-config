{ config, lib, ... }:

with lib;

let
  cfg = config.modules.wakatime;
  inherit (config.home) homeDirectory;
in
{
  options.modules.wakatime = {
    enable = mkEnableOption "Configure WakaTime with Wakapi";
  };

  config = mkIf cfg.enable {
    sops.secrets = {
      "wakatime/wakatime" = { };  # Unused
      "wakatime/wakapi".path = "${homeDirectory}/.wakatime.cfg";
      "wakatime/hackatime" = { };  # Unused
    };

    # Impermanence
    modules.impermanence.persistDirs = [ ".wakatime" ];
  };
}
