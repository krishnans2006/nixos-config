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
  };
}
