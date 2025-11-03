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
    ethernetOnly = false;
  };
  modules.bluetooth.enable = true;
  modules.printing.enable = true;
  modules.docker.enable = true;
  modules.tailscale = {
    enable = true;
    enableTaildrive = true;
    taildrivePath = "/home/krishnan/Filesystems/Tailscale";
  };
  modules.secure-boot.enable = true;
  modules.krishnan-user.enable = true;
  modules.fs-mounts = {
    tjcsl = true;
    ews = true;
  };

  modules.gaming.enable = false;
  modules.waydroid.enable = false;
  modules.virtualbox.enable = false;

  modules.hp-pen.enable = true;
  modules.yubikey-auth.enable = true;

  modules.packages = {
    logic2 = true;
    chipwhisperer = true;
  };

  networking.hostName = "krishnan-lap";  # Define your hostname.
}
