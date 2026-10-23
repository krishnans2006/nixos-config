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
    programs.zen-browser =
      let
        # Aliases for extensions
        extensions = {
          # Pinned
          darkreader = {
            id = "addon@darkreader.org";
            slug = "darkreader";
            pinned = true;
          };
          bitwarden = {
            id = "{446900e4-71c2-419f-a6a7-df9c091e268b}";
            slug = "bitwarden-password-manager";
            pinned = true;
          };
          ublock-origin = {
            id = "uBlock0@raymondhill.net";
            slug = "ublock-origin";
            pinned = true;
          };

          # Unpinned
          sponsorblock = {
            id = "sponsorBlocker@ajay.app";
            slug = "sponsorblock";
          };
          seven-tv = {
            id = "moz-addon-prod@7tv.app";
            slug = "7tv-extension";
          };
          improve-youtube = {
            id = "{3c6bf0cc-3ae2-42fb-9993-0d33104fdcaf}";
            slug = "youtube-addon";
          };
          violentmonkey = {
            id = "{aecec67f-0d10-4fa7-b7c7-609a2db280cf}";
            slug = "violentmonkey";
          };
          foxy-gestures = {
            id = "{e839c3f9-298e-4cd0-99e0-464431cb7c34}";
            slug = "foxy-gestures";
          };
          working-vpn = {
            id = "{6b1d4418-eff5-4ede-ae7c-950ab7476049}";
            slug = "workingvpn";
          };
          youtube-nonstop = {
            id = "{0d7cafdd-501c-49ca-8ebb-e3341caaa55e}";
            slug = "youtube-nonstop";
          };
          cookie-editor = {
            id = "{c3c10168-4186-445c-9c5b-63f12b8e2c87}";
            slug = "cookie-editor";
          };
          auto-claim-twitch-points = {
            id = "{8e1ef2d7-d78f-47f9-9b69-c2806eb534fc}";
            slug = "auto-claim-twitch-chnnl-points";
          };
          return-youtube-dislike = {
            id = "{762f9885-5a13-4abd-9c77-433dcd38b8fd}";
            slug = "return-youtube-dislikes";
          };
          foxyproxy = {
            id = "foxyproxy@eric.h.jung";
            slug = "foxyproxy-standard";
          };
          tab-unloader = {
            id = "tab-unloader-we@afnankhan";
            slug = "tab-unloader-we";
          };
          ttv-ad-blocker = {
            id = "{71e91189-9cd2-4e46-895d-bcc38f0053c4}";
            slug = "ttv-ab-twitch-ad-blocker";
          };
          wakatime = {
            id = "addons@wakatime.com";
            slug = "wakatimes";
          };
        };

        # Construct enterprise policy settings for an individual extension
        mkExtensionPolicy = ext: {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/${ext.slug}/latest.xpi";
          installation_mode = "force_installed";
          default_area = if (ext.pinned or false) then "navbar" else "menupanel";
        };

        # Build the complete ExtensionSettings policy attribute set
        extensionSettings =
          let
            installedExtensions = mapAttrs' (
              _: ext: nameValuePair ext.id (mkExtensionPolicy ext)
            ) extensions;
          in
          { "*" = { default_area = "menupanel"; }; } // installedExtensions;

        # Declarative Zen Mods
        mods = {
          add-new-tab-urlbar-icon = "378ba8b9-cd36-45f5-88df-595df5288795";
          better-unloaded-tabs = "f7c71d9a-bce2-420f-ae44-a64bd92975ab";
          custom-menubutton = "5bb07b6e-c89f-4f4a-a0ed-e483cc535594";
          superpins = "ad97bb70-0066-4e42-9b5f-173a5e42c6fc";
          vertical-split-tab-groups = "4c2bec61-7f6c-4e5c-bdc6-c9ad1aba1827";
          lean = "1e86cf37-a127-4f24-b919-d265b5ce29a0";
          bleeding-corners-fix = "7d577b21-4685-4db2-bb17-d39d08eec199";
        };
      in
      {
        enable = true;

        # Extensions via enterprise policies
        policies = {
          ExtensionSettings = extensionSettings;

          # Some in-extension settings
          "3rdparty".Extensions = {
            "${extensions.ublock-origin.id}" = {
              userSettings = [ [ "showIconBadge" "false" ] ];
            };
            "${extensions.bitwarden.id}" = {
              environment.base = "https://vault.krishy.dev";
            };
          };
        };

        profiles.default = {
          id = 0;
          name = "default";
          isDefault = true;

          settings = {
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
          };

          # Zen Mods
          mods = attrValues mods;

          # Pinned extension buttons (ordered)
          extensionButtons = {
            "nav-bar" = [
              extensions.darkreader.id
              extensions.bitwarden.id
              extensions.ublock-origin.id
            ];
          };

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

          # Essentials (pinned tabs)
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

    # Autostart
    xdg.configFile."autostart/zen-beta.desktop" = mkIf cfg.autostart {
      source = "${config.programs.zen-browser.package}/share/applications/zen-beta.desktop";
    };

    # Impermanence
    modules.impermanence.persistDirs = [ ".config/zen" ];
  };
}
