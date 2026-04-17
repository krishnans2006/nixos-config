{ config, lib, root, ... }:

with lib;

let
  cfg = config.modules.packages.zen-browser;
in
{
  imports = [
    "${root}/config/home/flatpak.nix"
  ];

  options.modules.packages.zen-browser = {
    enable = mkEnableOption "Install Zen Browser Flatpak";
    autostart = mkEnableOption "Enable autostart for Zen Browser";
  };

  config = mkIf cfg.enable {
    services.flatpak.packages = [ "app.zen_browser.zen" ];

    # Autostart
    xdg.configFile."autostart/app.zen_browser.zen.desktop" = mkIf cfg.autostart {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.local/share/flatpak/exports/share/applications/app.zen_browser.zen.desktop";
    };
  };
}
