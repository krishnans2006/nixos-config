{ inputs, root, ... }:

with inputs;

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware.nix

    # Base configuration
    "${root}/base/system.nix"

    # Custom modules
    (import-tree "${root}/modules/system")
  ];

  modules.impermanence.enable = false;
  modules.secrets.enable = true;

  modules.plasma.enable = true;
  modules.audio.enable = true;
  modules.networks = {
    enable = true;
    enableWifi = false;  # To avoid bluetooth issues (and since Ethernet is always plugged in)
  };
  modules.wake-on-lan = {
    enable = true;
    interfaces = [ "enp13s0" ];
  };
  modules.bluetooth.enable = true;
  modules.printing.enable = true;
  modules.docker.enable = true;
  modules.tailscale = {
    enable = true;
    enableNMIntegration = true;
    enableTaildrive = false;
  };
  modules.localsend.enable = false;
  modules.ssh-server.enable = true;
  modules.secure-boot.enable = false;
  modules.krishnan-user = {
    enable = true;
    enablePresetPassword = true;
  };
  modules.iphone.enable = true;

  modules.gaming.enable = true;
  modules.waydroid.enable = false;
  modules.virtualbox.enable = false;
  modules.vmware.enable = false;
  modules.yubikey-auth.enable = false;

  modules.asusd.enable = false;
  modules.hp-pen.enable = false;
  modules.amd-rx6600xt.enable = true;

  modules.packages = {
    logic2 = true;
    chipwhisperer = false;
  };

  # Custom config

  networking.hostName = "krishnan-pc";  # Define your hostname.

  time.timeZone = "America/Chicago";

  hardware.rtl-sdr.enable = true;
}
