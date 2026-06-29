{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.packages.zulip;
in
{
  options.modules.packages.zulip = {
    enable = mkEnableOption "Install Zulip";
    autostart = mkEnableOption "Enable autostart for Zulip";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ zulip ];

    # Zulip rewrites settings.json on startup
    # xdg.configFile would make it a read-only store symlink and hang on load
    home.activation.seedZulipSettings = let
      settings = (pkgs.formats.json { }).generate "settings.json" {
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
    in
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      config_dir="${config.xdg.configHome}/Zulip/config"
      settings="$config_dir/settings.json"
      mkdir -p "$config_dir"
      if [ ! -e "$settings" ] || [ -L "$settings" ]; then
        install -Dm644 ${settings} "$settings"
      fi
    '';

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
