{ ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware.nix

    # Custom modules
    ../../modules/plasma.nix
    ../../modules/audio.nix
    ../../modules/networks.nix
    ../../modules/bluetooth.nix
    ../../modules/printing.nix
    ../../modules/docker.nix
    ../../modules/tailscale.nix

    ../../modules/gaming.nix
    ../../modules/waydroid.nix
    ../../modules/virtualbox.nix

    ../../modules/secure-boot.nix
    ../../modules/hp-pen.nix

    # Base configuration
    ../../base/configuration.nix
  ];

  modules.plasma.enable = true;
  modules.audio.enable = true;
  modules.networks = {
    enable = true;
    ethernetOnly = true;  # To avoid bluetooth issues (and since Ethernet is always plugged in)
  };
  modules.bluetooth.enable = true;
  modules.printing.enable = true;
  modules.docker.enable = true;
  modules.tailscale = {
    enable = true;
    enableTaildrive = false;
  };

  modules.gaming.enable = true;
  modules.waydroid.enable = true;
  modules.virtualbox.enable = true;

  modules.secure-boot.enable = true;
  modules.hp-pen.enable = false;

  networking.hostName = "krishnan-pc"; # Define your hostname.
}
