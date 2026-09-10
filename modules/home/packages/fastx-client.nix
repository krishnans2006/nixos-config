{ config, lib, pkgs, root, ... }:

with lib;

let
  cfg = config.modules.packages.fastx-client;
  fastxClient = pkgs.qt6Packages.callPackage (root + "/custom/fastx-client.nix") { };
in
{
  options.modules.packages.fastx-client = {
    enable = mkEnableOption "Install FastX Client";
  };

  config = mkIf cfg.enable {
    home.packages = [ fastxClient ];

    # Qt QStandardPaths + client data
    modules.impermanence.persistDirs = [
      ".config/StarNet Communications"
      ".FastX"
    ];

    xdg.mimeApps.defaultApplications = {
      "x-scheme-handler/fastx" = [ "fastx-uri.desktop" ];
    };
  };
}
