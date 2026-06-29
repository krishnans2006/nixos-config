{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.packages.vesktop;
in
{
  options.modules.packages.vesktop = {
    enable = mkEnableOption "Install Vesktop (Discord client)";
    autostart = mkEnableOption "Enable autostart for Vesktop";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      vesktop
      #libunity  # required for vesktop
    ];

    # Impermanence
    modules.impermanence.persistDirs = [
      ".config/vesktop/sessionData/Local Storage"  # Discord is sandboxed into sessionData
      ".config/vesktop/settings"  # Synced settings for plugins, etc.
    ];
    modules.impermanence.persistFiles = [
      ".config/vesktop/settings.json"  # Vesktop settings (titlebar, tray, etc.)
      ".config/vesktop/state.json"  # Window params, first launch menu
    ];

    # Autostart
    xdg.configFile."autostart/vesktop.desktop" = mkIf cfg.autostart {
      text = builtins.replaceStrings [ "vesktop %U" ] [ "vesktop --start-minimized %U" ] (
        builtins.readFile "${pkgs.vesktop}/share/applications/vesktop.desktop"
      );
    };
  };
}
