{ inputs, root, ... }:

with inputs;

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware.nix

    # Base configuration
    "${root}/base/system.nix"

    # Profiles
    "${root}/profiles/desktop/system.nix"

    # Custom modules
    (import-tree "${root}/modules/system")
  ];

  # Custom config

  networking.hostName = "krishnan-pc";  # Define your hostname.
  time.timeZone = "America/Chicago";

  modules.impermanence.enable = false;

  modules.networks.enableWifi = false;  # To avoid bluetooth issues (and since Ethernet is always plugged in)
  modules.wake-on-lan = {
    enable = true;
    interfaces = [ "enp13s0" ];
  };
  modules.ssh-server.enable = true;

  modules.gaming.enable = true;
  modules.waydroid.enable = false;
  modules.virtualbox.enable = false;
  modules.vmware.enable = false;
  modules.yubikey-auth.enable = false;

  modules.amd-rx6600xt.enable = true;

  modules.packages.logic2 = true;

  hardware.rtl-sdr.enable = true;
}
