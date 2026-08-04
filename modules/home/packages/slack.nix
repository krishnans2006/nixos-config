{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.packages.slack;
in
{
  options.modules.packages.slack = {
    enable = mkEnableOption "Install Slack";
    autostart = mkEnableOption "Enable autostart for Slack";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ slack ];

    # Impermanence
    modules.impermanence.persistDirs = [
      ".config/Slack/storage"  # root-state.
      ".config/Slack/Local Storage"  # UI Preferences
    ];
    modules.impermanence.persistFiles = [
      ".config/Slack/Cookies"
    ];

    # Autostart
    xdg.configFile."autostart/slack.desktop" = mkIf cfg.autostart {
      text = builtins.replaceStrings [ "slack -s %U" ] [ "slack -s --startup %U" ] (
        builtins.readFile "${pkgs.slack}/share/applications/slack.desktop"
      );
    };
  };
}
