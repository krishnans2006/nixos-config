{ config, lib, ... }:

with lib;

let
  cfg = config.modules.flatpak;
in
{
  options.modules.flatpak = {
    enable = mkEnableOption "Enable Flatpak";
    #
  };

  config = mkIf cfg.enable {
    # Must be enabled in system config
    services.flatpak = {
      remotes = [
        {
          name = "flathub";
          location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
        }
      ];
      update.onActivation = true;

      # Populated by other modules (see modules/home/packages/*.nix)
      packages = [ ];
    };

    # Impermanence
    modules.impermanence.persistDirs = [ ".local/share/flatpak" ];
  };
}
