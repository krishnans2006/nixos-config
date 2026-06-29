{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.packages.zulip;

  formatter = pkgs.formats.json { };
in
{
  options.modules.packages.zulip = {
    enable = mkEnableOption "Install Zulip";
    autostart = mkEnableOption "Enable autostart for Zulip";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ zulip ];

    # Declarative config
    xdg.configFile."Zulip/config/settings.json".source = (
      formatter.generate "settings.json" {
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
      }
    );

    # Impermanence
    modules.impermanence.persistDirs = [
      ".config/Zulip/config"  # domain.json, settings.json
      ".config/Zulip/Partitions/webviewsession/Local Storage"
    ];
    modules.impermanence.persistFiles = [
      ".config/Zulip/Partitions/webviewsession/Cookies"
    ];

    # Autostart
    xdg.configFile."autostart/zulip.desktop" = mkIf cfg.autostart {
      text = builtins.readFile "${pkgs.zulip}/share/applications/zulip.desktop";
    };
  };
}
