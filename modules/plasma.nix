{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.plasma;
in {
  options.modules.plasma = {
    enable = mkEnableOption "Enable a customized KDE Plasma 6 DE";
  };

  config = mkIf cfg.enable {
    # Enable the X11 windowing system.
    services.xserver.enable = true;

    # Enable the KDE Plasma Desktop Environment.
    services.displayManager = {
      sddm.enable = true;
      autoLogin.enable = true;
      autoLogin.user = "krishnan";
    };
    services.desktopManager.plasma6.enable = true;

    # Fix blurry vscode
    environment.sessionVariables.NIXOS_OZONE_WL = "1";

    # Configure keymap in X11
    services.xserver.xkb = {
      layout = "us";
      variant = "";
    };

    # Enable KDE Connect (Phone Integration)
    programs.kdeconnect.enable = true;

    # Enable Partition Manager
    programs.partition-manager.enable = true;
  };
}
