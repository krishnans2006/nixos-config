{ ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware.nix

    # Custom modules
    ../../modules/plasma.nix
    ../../modules/networks.nix
    ../../modules/gaming.nix
    ../../modules/printing.nix
    ../../modules/waydroid.nix

    # Base configuration
    ../../base/configuration.nix
  ];

  modules.plasma.enable = true;
  modules.networks.enable = true;
  modules.gaming.enable = true;
  modules.printing.enable = true;
  modules.waydroid.enable = true;

  networking.hostName = "krishnan-pc"; # Define your hostname.
}
