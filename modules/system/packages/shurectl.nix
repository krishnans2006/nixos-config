{ config, lib, pkgs, root, ... }:

with lib;

let
  cfg = config.modules.shurectl;
  shurectl = pkgs.callPackage (root + "/custom/shurectl.nix") { };
in
{
  options.modules.shurectl = {
    enable = mkEnableOption "Install shurectl and udev rules for Shure USB audio devices";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ shurectl ];
    services.udev.packages = [ shurectl ];
  };
}
