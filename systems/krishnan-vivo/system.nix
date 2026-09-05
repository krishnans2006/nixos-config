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

    # Profiles
    "${root}/profiles/desktop/system.nix"

    # Custom modules
    (import-tree "${root}/modules/system")
  ];

  # Custom config

  networking.hostName = "krishnan-vivo";  # Define your hostname.

  time.timeZone = "America/Chicago";

  modules.impermanence.enable = true;

  modules.tailscale = {
    enableTaildrive = true;
    taildrivePath = "/home/krishnan/Filesystems/Tailscale";
  };

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

  # Force multimedia keys to be the default at boot (Fn lock OFF)
  boot.extraModprobeConfig = ''
    options asus_wmi fnlock_default=0
  '';
}
