{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.packages.zulip;
in
{
  options.modules.packages.zulip = {
    enable = mkEnableOption "Install Zulip";
    autostart = mkEnableOption "Enable autostart for Zulip";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ zulip ];

    # Impermanence
    modules.impermanence.persistDirs = [
      ".config/Zulip/config"  # domain.json, settings.json
      ".config/Zulip/Partitions/webviewsession/Local Storage"
    ];
    modules.impermanence.persistFiles = [
      ".config/Zulip/Partitions/webviewsession/Cookies"
    ];

    # Autostart
    xdg.configFile."autostart/zulip.desktop" = mkIf cfg.autostart {
      text = builtins.readFile "${pkgs.zulip}/share/applications/zulip.desktop";
    };
  };
}
