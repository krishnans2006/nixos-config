{ config, lib, ... }:

with lib;

let
  cfg = config.modules.graphics;
in
{
  options.modules.graphics = {
    enable = mkEnableOption "Enable base options that set up a graphical desktop environment (Wayland)";
    #
  };

  config = mkIf cfg.enable {
    # Enable the X11 windowing system.
    services.xserver.enable = true;

    # Fix blurry vscode
    environment.sessionVariables.NIXOS_OZONE_WL = "1";

    # Configure keymap in X11
    services.xserver.xkb = {
      layout = "us";
      variant = "";
    };

    # Enable flatpak
    # This requires a desktop environment! So it is intentionally here instead of capabilities/base, etc.
    services.flatpak.enable = true;
  };
}
