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
    programs.vesktop = {
      enable = true;

      settings = {
        discordBranch = "stable";
        arRPC = true;

        customTitleBar = true;
        hardwareVideoAcceleration = true;

        minimizeToTray = true;
        autoStartMinimized = false;
        clickTrayToShowHide = true;
        enableTaskbarFlashing = true;

        # splashColor = "rgb(239, 239, 241)";
        # splashBackground = "rgb(18, 18, 20)";
      };

      # This is handled by settings sync
      # vencord.settings = { ... }
    };

    # Impermanence
    modules.impermanence.persistDirs = [
      ".config/vesktop/sessionData/Local Storage"  # Discord is sandboxed into sessionData
      ".config/vesktop/settings"  # Synced settings for plugins, etc.
    ];
    modules.impermanence.persistFiles = [
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
