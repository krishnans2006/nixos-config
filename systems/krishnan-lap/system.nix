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

  networking.hostName = "krishnan-lap";  # Define your hostname.

  time.timeZone = "America/New_York";

  modules.impermanence.enable = true;

  modules.tailscale = {
    enableTaildrive = true;
    taildrivePath = "/home/krishnan/Filesystems/Tailscale";
  };

  modules.gaming.enable = false;
  modules.waydroid.enable = false;
  modules.virtualbox.enable = false;
  modules.vmware.enable = false;
  modules.yubikey-auth.enable = true;

  modules.hp-pen.enable = true;

  modules.packages = {
    logic2 = true;
    chipwhisperer = true;
  };

  # TODO: Maybe the first is unnecessary
  systemd.tpm2.enable = false;
  boot.initrd.systemd.tpm2.enable = false;

  nix.optimise = {
    automatic = true;
    persistent = true;
  };

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    priority = 5;
    memoryPercent = 50;
  };

  boot.tmp = {
    useTmpfs = true;
    tmpfsSize = "50%";
  };

  services.btrfs.autoScrub = {
    enable = true;
    interval = "weekly";
  };
}
