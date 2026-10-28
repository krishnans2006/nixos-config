{ config, lib, pkgs, root, ... }:

with lib;

let
  cfg = config.modules.zen-browser;
in
{
  options.modules.zen-browser = {
    enable = mkEnableOption "Enable Zen Browser";
    autostart = mkEnableOption "Enable autostart for Zen Browser";
  };

  config = mkIf cfg.enable (
    let
      data = import (root + "/data/zen-browser.nix");
      inherit (data)
        extensions
        spaces
        essentials
        mods
        ;

      # Construct enterprise policy settings for an individual extension
      mkExtensionPolicy = ext: {
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/${ext.slug}/latest.xpi";
        installation_mode = "force_installed";
        default_area = if (ext.pinned or false) then "navbar" else "menupanel";
      };

      # Build the complete ExtensionSettings policy attribute set
      baseExtensionSettings =
        let
          installedExtensions = mapAttrs' (
            _: ext: nameValuePair ext.id (mkExtensionPolicy ext)
          ) extensions;
        in
        { "*" = { default_area = "menupanel"; }; } // installedExtensions;

      # Pinned extension IDs ordered by pinOrder (lower = left, higher = right)
      sortedPinnedExtensionIds =
        let
          pinned = filter (ext: ext.pinned or false) (attrValues extensions);
          sorted = sort (a: b: (a.pinOrder or 0) < (b.pinOrder or 0)) pinned;
        in
        map (ext: ext.id) sorted;

      # In-extension enterprise policy settings ("3rdparty".Extensions)
      enterpriseExtensionSettings = mapAttrs' (_: ext: nameValuePair ext.id ext.enterpriseConfig) (
        filterAttrs (_: ext: ext ? enterpriseConfig) extensions
      );

      # Extensions configured via JSON storage
      jsonExtensions = filter (ext: ext ? localConfigFile) (attrValues extensions);

      # Extension data list formatted for zen-extension-update utility
      jsonExtensionData = map (ext: {
        inherit (ext) id;
        json = ext.localConfigFile;
      }) jsonExtensions;

      # Profile settings to force Gecko IndexedDB migration for JSON-configured extensions
      jsonExtensionSettings = listToAttrs (
        map (
          ext: nameValuePair "extensions.webextensions.ExtensionStorageIDB.migrated.${ext.id}" false
        ) jsonExtensions
      );

      # Helper to construct workspace definitions with auto-generated IDs and positions
      mkSpaces = spaces: listToAttrs (
        imap1 (
          idx: space:
          let
            s = "000000000000" + toString idx;
            pad = substring (stringLength s - 12) 12 s;
          in
          nameValuePair (toString idx) {
            id = "11111111-0001-4000-8000-${pad}";
            inherit (space) name icon;
            position = idx * 1000;
          }
        ) spaces
      );

      # Helper to construct essential pin definitions with auto-generated IDs and positions
      mkEssentials = urls: listToAttrs (
        imap1 (
          idx: url:
          let
            s = "000000000000" + toString idx;
            pad = substring (stringLength s - 12) 12 s;
          in
          nameValuePair (toString idx) {
            id = "22222222-0001-4000-8000-${pad}";
            inherit url;
            isEssential = true;
            position = idx;
          }
        ) urls
      );
    in
    {
      programs.zen-browser = {
        enable = true;

        profiles.default = {
          id = 0;
          name = "default";
          isDefault = true;

          settings = mkMerge [
            {
              # Restore previous session on startup (keep tabs and workspaces across restarts)
              "browser.startup.page" = 3;
              "zen.workspaces.continue-where-left-off" = true;

              # Firefox Sync configuration
              "services.sync.username" = "krishnans2006@gmail.com";
              "services.sync.engine.addons" = false;
              "services.sync.engine.history" = true;
              "services.sync.engine.prefs" = false;

              # Window sync required for essentials
              "zen.window-sync.enabled" = true;
              "zen.window-sync.sync-only-pinned-tabs" = true;

              # Don't show about:config warning
              "browser.aboutConfig.showWarning" = false;

              # Disable passwords and autofill (conflicts with Bitwarden)
              "signon.rememberSignons" = false;
              "signon.autofillForms" = false;
              "signon.generation.enabled" = false;
              "signon.management.page.breach-alerts.enabled" = false;
              "extensions.formautofill.creditCards.enabled" = false;
              "extensions.formautofill.addresses.enabled" = false;

              # Extension storage migration
              "extensions.webextensions.keepStorageOnUninstall" = true;

              # Disable default browser prompt
              "browser.shell.checkDefaultBrowser" = false;

              # Skip startup tutorial / welcome screen
              "zen.welcome-screen.seen" = true;
              "browser.aboutwelcome.enabled" = false;

              # Vertical tabs on the right side
              "zen.tabs.vertical.right-side" = true;

              # SuperPins mod configuration
              "uc.essentials.grid-count" = true;
              "mod.superpins.essentials.grid-count" = "5";

              # Lean mod configuration
              "mod.lean.top-workspace" = true;
              "mod.lean.bottom-buttons" = true;
            }

            jsonExtensionSettings
          ];

          # Zen Mods
          mods = attrValues mods;

          # Pinned extension buttons (ordered)
          extensionButtons."nav-bar" = sortedPinnedExtensionIds;

          # Keyboard shortcuts
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

          # Workspaces
          spacesForce = true;
          spaces = mkSpaces spaces;

          # Essentials (configured as part of pinned tabs)
          pinsForce = true;
          pinsForceAction = "remove";
          pins = mkEssentials essentials;
        };

        # Extension config via enterprise policies
        policies = {
          ExtensionSettings = baseExtensionSettings;
          "3rdparty".Extensions = enterpriseExtensionSettings;
        };
      };

      # Extension config via JSON -> local storage migration
      # This is a "workaround" for extensions that have their own backup/restore settings
      # and only use Gecko's IndexedDB for storing configuration
      home = import (root + "/utils/zen-extension-update.nix") {
        inherit lib pkgs;
      } jsonExtensionData;

      # Set as default browser
      xdg.mimeApps = {
        enable = true;
        defaultApplications = {
          "text/html" = [ "zen-beta.desktop" ];
          "text/xml" = [ "zen-beta.desktop" ];
          "application/xhtml+xml" = [ "zen-beta.desktop" ];
          "x-scheme-handler/http" = [ "zen-beta.desktop" ];
          "x-scheme-handler/https" = [ "zen-beta.desktop" ];
          "x-scheme-handler/about" = [ "zen-beta.desktop" ];
          "x-scheme-handler/unknown" = [ "zen-beta.desktop" ];
        };
      };
      xdg.configFile."mimeapps.list".force = true;

      # Autostart
      xdg.configFile."autostart/zen-beta.desktop" = mkIf cfg.autostart {
        source = "${config.programs.zen-browser.package}/share/applications/zen-beta.desktop";
      };

      # Impermanence
      modules.impermanence.persistDirs = [ ".config/zen" ];
    }
  );
}
