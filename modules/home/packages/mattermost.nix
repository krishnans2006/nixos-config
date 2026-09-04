{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.packages.mattermost;
in
{
  options.modules.packages.mattermost = {
    enable = mkEnableOption "Install Mattermost Desktop";
    autostart = mkEnableOption "Enable autostart for Mattermost";

    servers = mkOption {
      type = types.listOf (
        types.submodule {
          options = {
            name = mkOption {
              type = types.str;
              description = "Display name for the Mattermost server.";
            };
            url = mkOption {
              type = types.str;
              description = "Server URL.";
              example = "https://mattermost.example.com/";
            };
          };
        }
      );
      default = [
        {
          name = "TJ CSL";
          url = "https://mattermost.tjhsst.edu/";
        }
        {
          name = "Matterless";
          url = "https://matterless.tjhsst.edu/";
        }
      ];
      description = "Mattermost servers shown in the desktop app (written to config.json)";
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ mattermost-desktop ];

    # Mattermost rewrites config.json on startup/settings changes (writeFileSync).
    # xdg.configFile would make it a read-only store symlink and break the app.
    modules.seed-file.seedFiles = [
      {
        name = "seedMattermostConfig";
        file = ".config/Mattermost/config.json";
        force = true;
        source = (pkgs.formats.json { }).generate "config.json" {
          version = 4;
          servers = imap0 (order: s: {
            inherit (s) name url;
            inherit order;
            isPredefined = true;
          }) cfg.servers;
          showTrayIcon = true;
          trayIconTheme = "light";
          minimizeToTray = true;
          notifications = {
            flashWindow = 2;
            bounceIcon = true;
            bounceIconType = "informational";
          };
          showUnreadBadge = true;
          useSpellChecker = true;
          enableHardwareAcceleration = true;
          autostart = cfg.autostart;
          hideOnStart = cfg.autostart;
          spellCheckerLocales = [ ];
          darkMode = true;
          lastActiveServer = 0;
          downloadLocation = "${config.home.homeDirectory}/Downloads/Mattermost";
          startInFullscreen = false;
          logLevel = "info";
          enableMetrics = false;
          viewLimit = 15;
          themeSyncing = true;
          autoCheckForUpdates = true;
          alwaysMinimize = true;
          enableSentry = true;
          skippedVersions = [ ];
          useNativeTitleBar = false;
        };
      }
    ];

    # Impermanence
    modules.impermanence.persistDirs = [
      ".config/Mattermost/IndexedDB"
      ".config/Mattermost/Local Storage"
      #
    ];
    modules.impermanence.persistFiles = [
      ".config/Mattermost/Cookies"
      ".config/Mattermost/bounds-info.json"  # Window size/maximized
      ".config/Mattermost/permissions.json"  # Notifications allow/deny
    ];

    # Autostart
    xdg.configFile."autostart/mattermost.desktop" = mkIf cfg.autostart {
      text = builtins.readFile "${pkgs.mattermost-desktop}/share/applications/Mattermost.desktop";
    };
  };
}
