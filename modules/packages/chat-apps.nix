{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.packages.chat-apps;
in
{
  options.modules.packages.chat-apps = {
    enable = mkEnableOption "Install many chat apps";
    autostart = mkEnableOption "Enable autostart";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      vesktop
      discord-canary
      #libunity  # required for vesktop
      slack
      element-desktop
      signal-desktop
      mattermost-desktop
      zulip
    ];

    xdg.configFile = mkIf cfg.autostart (
      let
        # These variables read an app's desktop file from /nix/store
        # then modify the Exec= value to start the app minimized
        vesktopOld = builtins.readFile "${pkgs.vesktop}/share/applications/vesktop.desktop";
        vesktopNew = builtins.replaceStrings [ "vesktop %U" ] [ "vesktop -m %U" ] vesktopOld;

        slackOld = builtins.readFile "${pkgs.slack}/share/applications/slack.desktop";
        slackNew = builtins.replaceStrings [ "slack -s %U" ] [ "slack -s -u %U" ] slackOld;
      in {
        "autostart/vesktop.desktop".text = vesktopNew;
        "autostart/slack.desktop".text = slackNew;
      }
    );
  };
}
