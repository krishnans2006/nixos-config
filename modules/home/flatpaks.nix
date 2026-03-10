{ config, lib, osConfig, ... }:

with lib;

let
  cfg = config.modules.flatpaks;
in
{
  options.modules.tailscale = {
    zen-browser = mkEnableOption "Install Zen Browser Flatpak";
    bitwarden-desktop = mkEnableOption "Install Bitwarden Desktop Flatpak";
  };

  # Must be enabled in system config
  config = mkIf cfg.enable {
    services.flatpak = {
      remotes = [
        { name = "flathub"; location = "https://dl.flathub.org/repo/flathub.flatpakrepo"; }
      ];
      update.onActivation = true;
      packages = [
        (mkIf cfg.zen-browser "app.zen_browser.zen")
        (mkIf cfg.bitwarden-desktop "com.bitwarden.desktop")
      ];
    };
  };
}
