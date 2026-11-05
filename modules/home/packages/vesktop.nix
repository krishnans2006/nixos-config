{ config, lib, pkgs, root, ... }:

with lib;

let
  cfg = config.modules.vesktop;

  settings = import (root + "/data/vesktop-settings.nix");
in
{
  options.modules.vesktop = {
    enable = mkEnableOption "Install Vesktop (Discord client)";
    autostart = mkEnableOption "Enable autostart for Vesktop";
  };

  config = mkIf cfg.enable {
    programs.vesktop = {
      enable = true;

      settings = settings;

      # This is handled by settings sync
      # vencord.settings = { ... }
    };

    # Impermanence
    modules.impermanence.persistDirs = [
      ".config/vesktop/sessionData/Local Storage"  # Discord is sandboxed into sessionData
      ".config/vesktop/sessionData/IndexedDB"  # Vencord DataStore (Vencord_cloudSecret, etc.)
      ".config/vesktop/settings"  # Synced settings for plugins, etc.
    ];
    modules.impermanence.persistFiles = [
      ".config/vesktop/state.json"  # Window params, first launch menu (seeded once, then mutable)
    ];

    # Vesktop rewrites state.json at runtime; seed defaults only if missing/symlink
    home.activation = import (root + "/utils/seed-file.nix") { inherit lib config; } [
      {
        name = "seedVesktopState";
        file = ".config/vesktop/state.json";
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
