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
    ../../modules/secure-boot.nix
    ../../modules/krishnan-user.nix
    ../../modules/fs-mounts.nix
    ../../modules/iphone.nix

    ../../modules/gaming.nix
    ../../modules/waydroid.nix
    ../../modules/virtualbox.nix
  
    ../../modules/hp-pen.nix
    ../../modules/yubikey-auth.nix

    ../../modules/packages.nix

    # Base configuration
    ../../base/configuration.nix
  ];

  modules.plasma.enable = true;
  modules.audio.enable = true;
  modules.networks = {
    enable = true;
    enableWifi = false;  # To avoid bluetooth issues (and since Ethernet is always plugged in)
  };
  modules.bluetooth.enable = true;
  modules.printing.enable = true;
  modules.docker.enable = true;
  modules.tailscale = {
    enable = true;
    enableTaildrive = false;
  };
  modules.secure-boot.enable = false;
  modules.krishnan-user.enable = true;
  modules.fs-mounts = {
    tjcsl = true;
    ews = true;
  };
  modules.iphone.enable = true;

  modules.gaming.enable = true;
  modules.waydroid.enable = true;
  modules.virtualbox.enable = true;

  modules.hp-pen.enable = false;
  modules.yubikey-auth.enable = false;

  modules.packages = {
    logic2 = false;
    chipwhisperer = false;
  };

  networking.hostName = "krishnan-pc";  # Define your hostname.
}
