{ config, lib, pkgs, root, ... }:

with lib;

let
  cfg = config.modules.zulip;

  settings = import (root + "/data/zulip-settings.nix") { home = config.home.homeDirectory; };
in
{
  options.modules.zulip = {
    enable = mkEnableOption "Install Zulip";
    autostart = mkEnableOption "Enable autostart for Zulip";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ zulip ];

    # Zulip rewrites settings.json on startup
    # xdg.configFile would make it a read-only store symlink and hang on load
    home.activation = import (root + "/utils/seed-file.nix") { inherit lib config; } [
      {
        name = "seedZulipSettings";
        file = ".config/Zulip/config/settings.json";
        source = (pkgs.formats.json { }).generate "settings.json" settings;
      }
    ];

    # Impermanence
    modules.impermanence.persistDirs = [
      ".config/Zulip/config"  # domain.json, settings.json
      ".config/Zulip/Partitions/webviewsession/Local Storage"
    ];
    modules.impermanence.persistFiles = [
      ".config/Zulip/Partitions/webviewsession/Cookies"
      #
    ];

    # Autostart
    xdg.configFile."autostart/zulip.desktop" = mkIf cfg.autostart {
      text = builtins.readFile "${pkgs.zulip}/share/applications/zulip.desktop";
    };
  };
}
