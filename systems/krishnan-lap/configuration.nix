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
  modules.gaming.enable = false;
  modules.printing.enable = true;
  modules.waydroid.enable = false;

  networking.hostName = "krishnan-lap"; # Define your hostname.
}
