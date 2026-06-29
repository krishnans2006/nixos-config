{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.packages.element;
in
{
  options.modules.packages.element = {
    enable = mkEnableOption "Install Element (Matrix client)";
    autostart = mkEnableOption "Enable autostart for Element";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ element-desktop ];

    # Impermanence
    modules.impermanence.persistDirs = [
      ".config/Element/IndexedDB"  # E2E Keys, auth
      ".config/Element/EventStore"  # Seshat database for search
      ".config/Element/Local Storage"  # Session ids, theme
    ];
    modules.impermanence.persistFiles = [
      # This needs to be symlinked due to atomic write (copying temp file) shenanigans
      { file = ".config/Element/electron-config.json"; method = "symlink"; }
      ".config/Element/window-state.json"
    ];

    # Autostart
    xdg.configFile."autostart/element.desktop" = mkIf cfg.autostart {
      text = builtins.replaceStrings [ "element-desktop %u" ] [ "element-desktop --hidden %u" ] (
        builtins.readFile "${pkgs.element-desktop}/share/applications/element-desktop.desktop"
      );
    };
  };
}
