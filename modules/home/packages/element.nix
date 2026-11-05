{ config, lib, pkgs, root, ... }:

with lib;

let
  cfg = config.modules.element;

  data = import (root + "/data/element.nix");
  inherit (data) settings;
in
{
  options.modules.element = {
    enable = mkEnableOption "Install Element (Matrix client)";
    autostart = mkEnableOption "Enable autostart for Element";
  };

  config = mkIf cfg.enable {
    programs.element-desktop = {
      enable = true;

      settings = settings;
    };

    # Impermanence
    modules.impermanence.persistDirs = [
      ".config/Element/IndexedDB"  # E2E keys, encrypted access token
      ".config/Element/EventStore"  # Seshat database for search
      ".config/Element/Local Storage"  # Session ids, theme
    ];
    modules.impermanence.persistFiles = [ ".config/Element/window-state.json" ];

    # electron-store atomically renames over electron-config.json, which replaces
    # impermanence file symlinks and loses safeStorage pickle keys on reboot
    # So, use systemd-persist
    systemd.user.services =
      import (root + "/utils/systemd-persist.nix") { inherit lib pkgs config; }
        [
          {
            name = "element-electron-config";
            file = ".config/Element/electron-config.json";
          }
        ];

    # Autostart
    xdg.configFile."autostart/element.desktop" = mkIf cfg.autostart {
      text = builtins.replaceStrings [ "element-desktop %u" ] [ "element-desktop --hidden %u" ] (
        builtins.readFile "${pkgs.element-desktop}/share/applications/element-desktop.desktop"
      );
    };
  };
}
