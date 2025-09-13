{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.virtualbox;
in
{
  options.modules.virtualbox = {
    enable = mkEnableOption "Enable VirtualBox for running VMs";
  };

  config = mkIf cfg.enable {
    virtualisation.virtualbox.host.enable = true;
    virtualisation.virtualbox.host.enableExtensionPack = true;
    boot.kernelParams = [ "kvm.enable_virt_at_load=0" ];
    users.extraGroups.vboxusers.members = [ "krishnan" ];
  };
}
