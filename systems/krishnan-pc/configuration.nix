{ inputs, ... }:

with inputs;

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware.nix

    # Base configuration
    ../../base/configuration.nix

    # Custom modules
    (import-tree ../../modules/system)
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
