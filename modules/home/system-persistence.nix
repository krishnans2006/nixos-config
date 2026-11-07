{ config, lib, osConfig ? null, root, ... }:

with lib;

let
  cfg = config.modules.system-persistence;

  # This module does user-level persistence for apps that are installed at the system level
  # By checking whether the appropriate system-level module is enabled
  # See utils/verify-system.nix for details on how this works

  verify = option: import (root + "/utils/verify-system.nix") {
    inherit lib osConfig option;
    type = "optional";
  };

  gaming = verify "modules.gaming.enable";
  localsend = verify "modules.localsend.enable";
  logic2 = verify "modules.logic2.enable";
  virtualbox = verify "modules.virtualbox.enable";
  vmware = verify "modules.vmware.enable";
  waydroid = verify "modules.waydroid.enable";
in
{
  options.modules.system-persistence = {
    enable = mkEnableOption "user-level persistence for apps installed at the system level";
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf gaming.satisfied {
      modules.impermanence.persistDirs = [ ".steam" ".local/share/Steam" ];
    })

    (mkIf localsend.satisfied {
      modules.impermanence.persistDirs = [ ".local/share/org.localsend.localsend_app" ];
    })

    (mkIf logic2.satisfied {
      modules.impermanence.persistDirs = [ ".config/Logic" ];
    })

    (mkIf virtualbox.satisfied {
      modules.impermanence.persistDirs = [ ".config/VirtualBox" "VirtualBox VMs" ];
    })

    (mkIf vmware.satisfied {
      modules.impermanence.persistDirs = [ ".vmware" "vmware" ];
    })

    (mkIf waydroid.satisfied {
      modules.impermanence.persistDirs = [ ".local/share/waydroid" ];
    })
  ]);
}
