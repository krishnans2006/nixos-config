{ inputs, lib, root, ... }:

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
    (root + "/profiles/headless/system.nix")

    # Custom modules
    (import-tree (root + "/modules/system"))
  ];

  # Custom config

  networking.hostName = "krishnan-mew";  # Define your hostname.
  time.timeZone = "America/Chicago";

  modules.secrets.enable = lib.mkForce false;  # Secrets-free config

  modules.krishnan-user.enablePresetPassword = lib.mkForce false;  # (needs secrets)

  # Static IP
  networking.useDHCP = false;
  networking.interfaces."ens18" = {
    useDHCP = false;
    ipv4.addresses = [
      {
        address = "23.152.236.215";
        prefixLength = 24;
      }
    ];
  };
  networking.defaultGateway = "23.152.236.1";

  # QEMU Guest Agent
  services.qemuGuest.enable = true;
}
