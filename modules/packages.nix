{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.packages;
in
{
  options.modules.packages = {
    logic2 = mkEnableOption "Install Saleae Logic 2";
    chipwhisperer = mkEnableOption "Install ChipWhisperer support";
  };

  config = mkMerge [
    (mkIf cfg.logic2 {
      environment.systemPackages = [ pkgs.saleae-logic-2 ];

      # Udev rules
      hardware.saleae-logic.enable = true;
    })

    (mkIf cfg.chipwhisperer {
      users.groups."chipwhisperer" = {};
      users.users."krishnan".extraGroups = [ "chipwhisperer" ];

      services.udev.extraRules = ''
        ## NewAE .rules file to enable ChipWhisperer to easily take control
        #
        # To use this file
        # 1) Unplug all NewAE hardware
        # 2) Copy to /etc/udev/rules.d/
        # 3) Reset the udev system:
        #    $ sudo udevadm control --reload-rules
        # 4) sudo usermod -aG chipwhisperer $USER
        # 5) Log in/out again for changes to take effect
        # 6) Connect hardware
        #
        # uaccess 
        # Match all CW devices and serial ports
        #   SUBSYSTEMS=="usb", ATTRS{idVendor}=="2b3e", ATTRS{idProduct}=="*", TAG+="uaccess"
        #   SUBSYSTEM=="tty", ATTRS{idVendor}=="2b3e", ATTRS{idProduct}=="*", TAG+="uaccess", SYMLINK+="cw_serial%n"
        #   SUBSYSTEM=="tty", ATTRS{idVendor}=="03eb", ATTRS{idProduct}=="6124" TAG+="uaccess", SYMLINK+="cw_bootloader%n"

        SUBSYSTEMS=="usb", ATTRS{idVendor}=="2b3e", ATTRS{idProduct}=="*", MODE="0664", GROUP="chipwhisperer"
        SUBSYSTEM=="tty", ATTRS{idVendor}=="2b3e", ATTRS{idProduct}=="*", MODE="0664", GROUP="chipwhisperer", SYMLINK+="cw_serial%n"
        SUBSYSTEM=="tty", ATTRS{idVendor}=="03eb", ATTRS{idProduct}=="6124", MODE="0664", GROUP="chipwhisperer", SYMLINK+="cw_bootloader%n"
      '';
    })
  ];
}
