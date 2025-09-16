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
  modules.networks.enable = true;
  modules.bluetooth.enable = true;
  modules.printing.enable = true;
  modules.docker.enable = true;
  modules.tailscale = {
    enable = true;
    enableTaildrive = true;
    taildrivePath = "/home/krishnan/Filesystems/Tailscale";
  };

  modules.gaming.enable = false;
  modules.waydroid.enable = false;
  modules.virtualbox.enable = false;

  modules.secure-boot.enable = true;
  modules.hp-pen.enable = true;

  networking.hostName = "krishnan-lap"; # Define your hostname.
}
