{ config, lib, ... }:

with lib;

let
  cfg = config.modules.zen-browser;
in
{
  options.modules.zen-browser = {
    enable = mkEnableOption "Enable Zen Browser";
    autostart = mkEnableOption "Enable autostart for Zen Browser";
  };

  config = mkIf cfg.enable {
    # Declarative Zen Browser from flake
    programs.zen-browser = {
      enable = true;

      profiles.default = {
        id = 0;
        name = "default";
        isDefault = true;

        settings = {
          # Firefox Sync configuration
          "services.sync.username" = "krishnans2006@gmail.com";
          "services.sync.engine.addons" = true;
          "services.sync.engine.history" = true;
          "services.sync.engine.prefs" = false;

          # Window sync required for essentials
          "zen.window-sync.enabled" = true;
          "zen.window-sync.sync-only-pinned-tabs" = true;

          # Don't show about:config warning
          "browser.aboutConfig.showWarning" = false;
        };

        # Declarative mods (theme store UUIDs)
        mods = [
          "378ba8b9-cd36-45f5-88df-595df5288795"  # Add new tab urlbar icon
          "f7c71d9a-bce2-420f-ae44-a64bd92975ab"  # Better Unloaded Tabs
          "5bb07b6e-c89f-4f4a-a0ed-e483cc535594"  # Custom MenuButton
          "ad97bb70-0066-4e42-9b5f-173a5e42c6fc"  # SuperPins
          "4c2bec61-7f6c-4e5c-bdc6-c9ad1aba1827"  # Vertical Split Tab Groups
          "1e86cf37-a127-4f24-b919-d265b5ce29a0"  # Lean
          "7d577b21-4685-4db2-bb17-d39d08eec199"  # Bleeding Corners Fix
        ];

        # Declarative pinned extensions on toolbar
        extensionButtons = {
          "nav-bar" = [
            "ublock0_raymondhill_net-browser-action"
            "_446900e4-71c2-419f-a6a7-df9c091e268b_-browser-action"
            "addon_darkreader_org-browser-action"
          ];
        };

        # Declarative keyboard shortcuts (only modified ones)
        keyboardShortcutsVersion = 21;
        keyboardShortcuts = [
          {
            id = "zen-compact-mode-toggle";
            key = "c";
            modifiers = {
              accel = true;
              alt = true;
            };
          }
        ];

        # Declarative workspaces (6 workspaces with circle icons and default dark gray theme)
        spacesForce = true;
        spaces = {
          "1" = {
            id = "11111111-0001-4000-8000-000000000001";
            name = "";
            icon = "🔴";
            position = 1000;
          };
          "2" = {
            id = "11111111-0001-4000-8000-000000000002";
            name = "";
            icon = "🟠";
            position = 2000;
          };
          "3" = {
            id = "11111111-0001-4000-8000-000000000003";
            name = "";
            icon = "🟡";
            position = 3000;
          };
          "4" = {
            id = "11111111-0001-4000-8000-000000000004";
            name = "";
            icon = "🟢";
            position = 4000;
          };
          "5" = {
            id = "11111111-0001-4000-8000-000000000005";
            name = "";
            icon = "🔵";
            position = 5000;
          };
          "6" = {
            id = "11111111-0001-4000-8000-000000000006";
            name = "";
            icon = "🟣";
            position = 6000;
          };
        };

        # Declarative essentials (pinned tabs)
        pinsForce = true;
        pinsForceAction = "remove";
        pins = {
          "Gmail" = {
            id = "22222222-0001-4000-8000-000000000001";
            url = "https://mail.google.com/mail/u/0/";
            isEssential = true;
            position = 1;
          };
          "School Mail" = {
            id = "22222222-0001-4000-8000-000000000002";
            url = "https://mail.google.com/mail/u/1/";
            isEssential = true;
            position = 2;
          };
          "Google Calendar" = {
            id = "22222222-0001-4000-8000-000000000003";
            url = "https://calendar.google.com/calendar/u/0/r";
            isEssential = true;
            position = 3;
          };
          "YouTube" = {
            id = "22222222-0001-4000-8000-000000000004";
            url = "https://www.youtube.com/";
            isEssential = true;
            position = 4;
          };
          "YouTube Music" = {
            id = "22222222-0001-4000-8000-000000000005";
            url = "https://music.youtube.com/";
            isEssential = true;
            position = 5;
          };
        };
      };
    };

    # Flatpak Zen Browser (imperative version for reference/testing)
    # modules.flatpak.enable = mkForce true;
    # services.flatpak.packages = [ "app.zen_browser.zen" ];

    # Autostart declarative version
    xdg.configFile."autostart/zen-beta.desktop" = mkIf cfg.autostart {
      source = "${config.programs.zen-browser.package}/share/applications/zen-beta.desktop";
    };

    # Persistence: both declarative (~/.config/zen) and Flatpak (~/.var/app/app.zen_browser.zen)
    modules.impermanence.persistDirs = [
      ".config/zen"
      # ".var/app/app.zen_browser.zen"
    ];
  };
}
