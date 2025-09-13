{ ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware.nix

    # Custom modules
    ../../modules/plasma.nix
    ../../modules/networks.nix
    ../../modules/bluetooth.nix
    ../../modules/printing.nix

    ../../modules/gaming.nix
    ../../modules/waydroid.nix
    ../../modules/virtualbox.nix

    ../../modules/hp-pen.nix

    # Base configuration
    ../../base/configuration.nix
  ];

  modules.plasma.enable = true;
  modules.networks.enable = true;
  modules.bluetooth.enable = true;
  modules.printing.enable = true;

  modules.gaming.enable = true;
  modules.waydroid.enable = true;
  modules.virtualbox.enable = true;

  modules.hp-pen.enable = false;

  networking.hostName = "krishnan-pc"; # Define your hostname.
}
