{ inputs, lib, root, ... }:

with inputs;

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware.nix

    # Disk configuration (disko)
    ./disk.nix

    # Base configuration
    "${root}/base/system.nix"

    # Custom modules
    (import-tree "${root}/modules/system")
  ];

  modules.impermanence.enable = false;
  modules.secrets.enable = lib.mkForce false;

  modules.plasma.enable = false;
  modules.audio.enable = false;
  modules.networks = {
    enable = false;
  };
  modules.bluetooth.enable = false;
  modules.printing.enable = false;
  modules.docker.enable = false;
  modules.tailscale = {
    enable = true;
    enableTaildrive = false;
  };
  modules.localsend.enable = false;
  modules.ssh-server.enable = false;
  modules.secure-boot.enable = false;
  modules.krishnan-user = {
    enable = true;
    enablePresetPassword = false;
  };
  modules.iphone.enable = false;

  modules.gaming.enable = false;
  modules.waydroid.enable = false;
  modules.virtualbox.enable = false;
  modules.vmware.enable = false;

  modules.asusd.enable = false;
  modules.hp-pen.enable = false;
  modules.yubikey-auth.enable = false;

  modules.packages = {
    logic2 = false;
    chipwhisperer = false;
  };

  # Custom config

  networking.hostName = "krishnan-mew";  # Define your hostname.

  time.timeZone = "America/Chicago";
}
