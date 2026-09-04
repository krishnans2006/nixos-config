{ config, lib, pkgs, root, ... }:

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

    # Mattermost rewrites these JSON files at runtime (writeFileSync)
    # xdg.configFile would make them read-only store symlinks and break the app
    home.activation = import "${root}/utils/seed-file.nix" { inherit lib config; } [
      {
        name = "seedMattermostConfig";
        file = ".config/Mattermost/config.json";
        force = true;
        source = (pkgs.formats.json { }).generate "config.json" {
          version = 4;
          servers = imap0 (order: s: {
            inherit (s) name url;
            inherit order;
            # isPredefined in config.json is only honored when the same URL also
            # exists in buildConfig/GPO; otherwise Mattermost drops the server and
            # rewrites servers to []
            isPredefined = false;
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
      {
        name = "seedMattermostPermissions";
        file = ".config/Mattermost/permissions.json";
        force = true;
        # Keys are URL origins (no trailing slash), matching Mattermost's lookup
        source = (pkgs.formats.json { }).generate "permissions.json" (
          listToAttrs (
            map (s: {
              name = removeSuffix "/" s.url;
              value.notifications.allowed = true;
            }) cfg.servers
          )
        );
      }
      {
        name = "seedMattermostBounds";
        file = ".config/Mattermost/bounds-info.json";
        source = (pkgs.formats.json { }).generate "bounds-info.json" {
          maximized = true;
          fullscreen = false;
          # Just don't set x, y, width, height (they get auto-set by Mattermost)
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
      ".config/Mattermost/bounds-info.json"  # Window size/maximized (seeded once, then mutable)
    ];

    # Autostart
    xdg.configFile."autostart/mattermost.desktop" = mkIf cfg.autostart {
      text = builtins.readFile "${pkgs.mattermost-desktop}/share/applications/Mattermost.desktop";
    };
  };
}
