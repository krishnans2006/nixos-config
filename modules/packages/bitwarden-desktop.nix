{ config, lib, root, ... }:

with lib;

let
  cfg = config.modules.packages.bitwarden-desktop;
in
{
  imports = [
    "${root}/config/home/flatpak.nix"
  ];

  options.modules.packages.bitwarden-desktop = {
    enable = mkEnableOption "Install Bitwarden Desktop Flatpak";
    autostart = mkEnableOption "Enable autostart for Bitwarden Desktop";
  };

  config = mkIf cfg.enable {
    services.flatpak.packages = [ "com.bitwarden.desktop" ];

    # Autostart
    xdg.configFile."autostart/bitwarden.desktop" = mkIf cfg.autostart {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.local/share/flatpak/exports/share/applications/com.bitwarden.desktop.desktop";
    };
  };
}
