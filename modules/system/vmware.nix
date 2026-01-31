{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.vmware;
in
{
  options.modules.vmware = {
    enable = mkEnableOption "Enable VMWare Workstation for running VMs";
  };

  config = mkIf cfg.enable {
    virtualisation.vmware.host.enable = true;
    environment.systemPackages = with pkgs; [
      vmware-workstation
    ];
    boot.kernelParams = [ "kvm.enable_virt_at_load=0" ];
  };
}
