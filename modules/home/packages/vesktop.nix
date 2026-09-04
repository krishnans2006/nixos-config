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
      ".config/vesktop/state.json"  # Window params, first launch menu (seeded once, then mutable)
    ];

    # Vesktop rewrites state.json at runtime; seed defaults only if missing/symlink
    modules.seed-file.seedFiles = [
      {
        name = "seedVesktopState";
        file = ".config/vesktop/state.json";
        force = false;
        source = (pkgs.formats.json { }).generate "state.json" {
          firstLaunch = false;
          maximized = true;
          minimized = false;
        };
      }
    ];

    # Autostart
    xdg.configFile."autostart/vesktop.desktop" = mkIf cfg.autostart {
      text = builtins.replaceStrings [ "vesktop %U" ] [ "vesktop --start-minimized %U" ] (
        builtins.readFile "${pkgs.vesktop}/share/applications/vesktop.desktop"
      );
    };
  };
}
