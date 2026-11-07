{ config, lib, ... }:

with lib;

let
  cfg = config.modules.docker;
in
{
  options.modules.docker = {
    enable = mkEnableOption "Enable Docker";
    #
  };

  config = mkIf cfg.enable {
    virtualisation.docker.enable = true;

    users.users."krishnan".extraGroups = [ "docker" ];

    # Containers, images, and volumes are stored in /var/lib/docker
    # So no need to persist anything
    # ~/.docker can be deleted at any time
  };
}
