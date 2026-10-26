{ config, lib, pkgs, root, ... }:

with lib;

let
  cfg = config.modules.jellybox;
  jellybox = pkgs.callPackage (root + "/custom/jellybox.nix") { };
in
{
  options.modules.jellybox = {
    enable = mkEnableOption "Install JellyBox (Jellyfin music player)";
  };

  config = mkIf cfg.enable {
    home.packages = [ jellybox ];

    modules.impermanence.persistDirs = [
      ".local/share/com.prodigytech.jellybox"
      ".config/com.prodigytech.jellybox"
    ];
  };
}
