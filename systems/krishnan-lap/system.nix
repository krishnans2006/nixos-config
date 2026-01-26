{ inputs, ... }:

with inputs;

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware.nix

    # Base configuration
    ../../base/system.nix

    # Custom modules
    (import-tree ../../modules/system)
  ];

  modules.plasma.enable = true;
  modules.audio.enable = true;
  modules.networks = {
    enable = true;
    enableWifi = true;
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
  modules.iphone.enable = true;

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

  systemd.tpm2.enable = false;

  nix.optimise = {
    automatic = true;
    persistent = true;
  };
}
