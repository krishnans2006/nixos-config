{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.packages.mattermost;
in
{
  options.modules.packages.mattermost = {
    enable = mkEnableOption "Install Mattermost Desktop";
    autostart = mkEnableOption "Enable autostart for Mattermost";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ mattermost-desktop ];

    # Impermanence
    modules.impermanence.persistDirs = [
      ".config/Mattermost/IndexedDB"
      ".config/Mattermost/Local Storage"
    ];
    modules.impermanence.persistFiles = [
      ".config/Mattermost/Cookies"
      ".config/Mattermost/config.json"  # Settings, servers (TODO: declarative?)
      ".config/Mattermost/bounds-info.json"  # Window size/maximized
      ".config/Mattermost/permissions.json"  # Notifications allow/deny
    ];

    # Autostart
    xdg.configFile."autostart/mattermost.desktop" = mkIf cfg.autostart {
      text = builtins.readFile "${pkgs.mattermost-desktop}/share/applications/Mattermost.desktop";
    };
  };
}
