{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.impermanence;
in
{
  options.modules.impermanence = {
    enable = mkEnableOption "Enable base impermanence persistence configuration";
  };

  config = mkIf cfg.enable {
    home.persistence."/persist" = {
      directories = [
        "Documents"
        "Downloads"
        "Music"
        "Pictures"
        "Videos"

        "School"
        "Tech"

        { directory = ".ssh"; mode = "0700"; }
        { directory = ".gnupg"; mode = "0700"; }
        ".local/share/direnv"
      ];
    };
  };
}
