{ inputs, root, ... }:

with inputs;

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware.nix

    # Disk configuration (disko)
    ./disk.nix

    # Profiles
    (root + "/profiles/base/system.nix")
    (root + "/profiles/default/system.nix")
    (root + "/profiles/desktop/system.nix")

    # Custom modules
    (import-tree (root + "/modules/system"))
  ];

  # Custom config

  networking.hostName = "krishnan-lap";  # Define your hostname.

  time.timeZone = "America/New_York";

  modules.btrfs.enable = true;
  modules.impermanence.enable = true;

  modules.plasma.autoLogin = true;

  modules.tailscale.enableTaildrive = true;

  modules.steam.enable = false;
  modules.waydroid.enable = false;
  modules.virtualbox.enable = false;
  modules.vmware.enable = false;
  modules.yubikey-auth.enable = true;

  modules.hp-pen.enable = true;

  modules.logic2.enable = true;
  modules.chipwhisperer.enable = true;

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
}
