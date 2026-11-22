{ config, lib, ... }:

with lib;

let
  cfg = config.modules.plasma;
in
{
  options.modules.plasma = {
    enable = mkEnableOption "Enable a customized KDE Plasma 6 DE";
    autoLogin = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to enable auto-login for the primary local user";
    };
  };

  config = mkIf cfg.enable {
    # Base graphics config
    modules.graphics.enable = mkForce true;

    # Enable the KDE Plasma Desktop Environment.
    services.displayManager = {
      sddm.enable = true;
      autoLogin.enable = cfg.autoLogin;
      autoLogin.user = config.modules.primary-user.username;
    };
    services.desktopManager.plasma6.enable = true;

    # Enable KDE Connect (Phone Integration)
    programs.kdeconnect.enable = true;

    # Enable Partition Manager
    programs.partition-manager.enable = true;
  };
}
