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

  modules.asusd.enable = false;
  modules.hp-pen.enable = true;
  modules.yubikey-auth.enable = true;

  modules.packages = {
    logic2 = true;
    chipwhisperer = true;
  };

  networking.hostName = "krishnan-lap";  # Define your hostname.

  time.timeZone = "America/New_York";

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
