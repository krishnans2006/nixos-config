{ config, lib, ... }:

with lib;

let
  cfg = config.modules.btrfs;
in
{
  options.modules.btrfs = {
    enable = mkEnableOption "Enable Btrfs support and maintenance";
    #
  };

  config = mkIf cfg.enable {
    boot.initrd.supportedFilesystems = [ "btrfs" ];

    services.btrfs.autoScrub = {
      enable = true;
      interval = "monthly";
    };
  };
}
