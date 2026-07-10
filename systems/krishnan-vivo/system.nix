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
  modules.localsend.enable = false;
  modules.ssh-server.enable = false;
  modules.secure-boot.enable = false;
  modules.krishnan-user.enable = true;
  modules.iphone.enable = true;

  modules.gaming.enable = false;
  modules.waydroid.enable = false;
  modules.virtualbox.enable = false;
  modules.vmware.enable = false;

  modules.asusd = {
    enable = true;
    chargeLimit = 80;
  };
  modules.hp-pen.enable = false;
  modules.yubikey-auth.enable = true;

  modules.packages = {
    logic2 = false;
    chipwhisperer = false;
  };

  networking.hostName = "krishnan-vivo";  # Define your hostname.

  time.timeZone = "America/New_York";
}
