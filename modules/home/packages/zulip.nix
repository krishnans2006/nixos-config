{ config, lib, pkgs, root, ... }:

with lib;

let
  cfg = config.modules.packages.zulip;
in
{
  options.modules.packages.zulip = {
    enable = mkEnableOption "Install Zulip";
    autostart = mkEnableOption "Enable autostart for Zulip";

    domains = mkOption {
      type = types.listOf (
        types.submodule {
          options = {
            url = mkOption {
              type = types.str;
              description = "Zulip organization URL.";
              example = "https://example.zulipchat.com";
            };
            alias = mkOption {
              type = types.str;
              description = "Display name for the organization.";
            };
          };
        }
      );
      default = [ ];
      description = "Zulip organizations shown in the desktop app (written to domain.json)";
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ zulip ];

    # Zulip rewrites settings.json on startup
    # xdg.configFile would make it a read-only store symlink and hang on load
    home.activation = import "${root}/utils/seed-file.nix" { inherit lib config; } [
      {
        name = "seedZulipSettings";
        file = ".config/Zulip/config/settings.json";
        source = (pkgs.formats.json { }).generate "settings.json" {
          appLanguage = "en";
          enableSpellchecker = true;
          spellcheckerLanguages = null;
          autoHideMenubar = true;
          silent = false;
          startMinimized = true;
          trayIcon = true;
          useSystemProxy = false;
          useManualProxy = false;
          autoUpdate = true;
          showSidebar = true;
          badgeOption = true;
          startAtLogin = true;  # Maybe false?
          showNotification = true;
          betaUpdate = false;
          errorReporting = false;
          customCSS = false;
          lastActiveTab = 0;
          dnd = false;
          dndPreviousSettings = {
            showNotification = true;
            silent = false;
          };
          downloadsPath = "${config.home.homeDirectory}/Downloads/Zulip";
          quitOnClose = false;
          promptDownload = false;
          proxyPAC = "";
          proxyRules = "";
          proxyBypass = "";
        };
      }
      {
        name = "seedZulipDomain";
        file = ".config/Zulip/config/domain.json";
        source = (pkgs.formats.json { }).generate "domain.json" {
          domains = map (d: {
            inherit (d) url alias;
          }) cfg.domains;
        };
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
