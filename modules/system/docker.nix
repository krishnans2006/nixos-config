{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.docker;
in
{
  options.modules.docker = {
    enable = mkEnableOption "Enable Docker";
  };

  config = mkIf cfg.enable {
    virtualisation.docker.enable = true;

    users.users."krishnan".extraGroups = [ "docker" ];
  };
}
