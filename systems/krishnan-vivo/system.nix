{ inputs, root, ... }:

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

  modules.impermanence.enable = true;
  modules.secrets.enable = true;

  modules.plasma.enable = true;
  modules.audio.enable = true;
  modules.networking.enable = true;
  modules.networks = {
    enable = true;
    enableWifi = true;
  };
  modules.wake-on-lan.enable = false;
  modules.bluetooth.enable = true;
  modules.printing.enable = true;
  modules.docker.enable = true;
  modules.tailscale = {
    enable = true;
    enableNMIntegration = true;
    enableTaildrive = true;
    taildrivePath = "/home/krishnan/Filesystems/Tailscale";
  };
  modules.localsend.enable = false;
  modules.ssh-server.enable = false;
  modules.secure-boot.enable = false;
  modules.krishnan-user = {
    enable = true;
    enablePresetPassword = true;
  };
  modules.iphone.enable = true;

  modules.gaming.enable = false;
  modules.waydroid.enable = true;
  modules.virtualbox.enable = false;
  modules.vmware.enable = false;
  modules.yubikey-auth.enable = true;

  modules.asusd = {
    enable = true;
    chargeLimit = 80;
  };
  modules.vivo-kbd-rgb = {
    # M5406WA uses ITE5570 HID LampArray
    enable = true;
    mode = "rainbow";
  };
  modules.hp-pen.enable = false;
  modules.amd-rx6600xt.enable = false;

  modules.packages = {
    logic2 = false;
    chipwhisperer = false;
  };

  # Custom config

  networking.hostName = "krishnan-vivo";  # Define your hostname.

  time.timeZone = "America/Chicago";

  # Force multimedia keys to be the default at boot (Fn lock OFF)
  boot.extraModprobeConfig = ''
    options asus_wmi fnlock_default=0
  '';
}
