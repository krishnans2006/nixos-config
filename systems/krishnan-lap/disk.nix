# Inspired by:
# - https://saylesss88.github.io/installation/enc/enc_install.html#the-install
# - https://github.com/nix-community/disko/blob/878ec37d6a8f52c6c801d0e2a2ad554c75b9353c/example/luks-btrfs-subvolumes.nix
# - https://github.com/Mewski/nixos-config/blob/26295640a68094692613a7b11def78b950ad00e3/modules/hosts/zephyrus/disko.nix
# - https://github.com/Misterio77/nix-config/blob/ffd3478bda5dbe53235d25898ba39585f9e088f4/hosts/atlas/hardware-configuration.nix
let
  btrfsMountOptions = [ "compress=zstd" "noatime" "space_cache=v2" "discard=async" ];
in {
  disko.devices.disk.main = {
    type = "disk";
    device = "/dev/disk/by-id/nvme-KBG30ZMV256G_TOSHIBA_78IPC0XWP12P";
    content = {
      type = "gpt";
      partitions = {
        # EFI System Partition
        ESP = {
          label = "boot";
          name = "ESP";
          size = "1G";  # Large because systemd-boot + Lanzaboote + multiple generations
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [
              "defaults"
              "umask=0077"  # Only root rwx
            ];
          };
        };
        luks = {
          label = "luks";
          size = "100%";
          content = {
            type = "luks";
            name = "crypt";
            settings.allowDiscards = true;
            content = {
              type = "btrfs";
              extraArgs = ["-L" "nixos" "-f"];
              # Snapshot /root to /root-blank on creation
              # This is what gets restored on each boot
              postCreateHook = ''
                MNTPOINT=$(mktemp -d)
                mount -t btrfs "$device" "$MNTPOINT"
                trap 'umount $MNTPOINT; rm -d $MNTPOINT' EXIT
                btrfs subvolume snapshot -r $MNTPOINT/root $MNTPOINT/root-blank
                btrfs subvolume snapshot -r $MNTPOINT/home $MNTPOINT/home-blank
              '';
              subvolumes = {
                # Each subvolume below gets its own snapshot (see postCreateHook above)
                # So everything that we want to restore independently should be in its own subvolume
                "/root" = {
                  mountpoint = "/";
                  mountOptions = [ "subvol=root" ] ++ btrfsMountOptions;
                };
                "/home" = {
                  mountpoint = "/home";
                  mountOptions = [ "subvol=home" ] ++ btrfsMountOptions;
                };
                # Delete on boot, but don't restore from a blank snapshot since it's not worth it
                "/var/cache" = {
                  mountpoint = "/var/cache";
                  mountOptions = [ "subvol=cache" ] ++ btrfsMountOptions;
                };
                # Do not delete or restore /var/log, /var/lib
                # Since logs should be preserved and lib is persistent data
                "/var/log" = {
                  mountpoint = "/var/log";
                  mountOptions = [ "subvol=log" ] ++ btrfsMountOptions;
                };
                "/var/lib" = {
                  mountpoint = "/var/lib";
                  mountOptions = [ "subvol=lib" ] ++ btrfsMountOptions;
                };
                # These special directories also shouldn't get deleted/restored
                "/nix" = {
                  mountpoint = "/nix";
                  mountOptions = [ "subvol=nix" ] ++ btrfsMountOptions;
                };
                "/persist" = {
                  mountpoint = "/persist";
                  mountOptions = [ "subvol=persist" ] ++ btrfsMountOptions;
                };
                # Swap
                # See https://github.com/nix-community/disko/blob/878ec37d6a8f52c6c801d0e2a2ad554c75b9353c/lib/types/btrfs.nix
                # Which does some fancy magic to create a swapfile on a btrfs subvolume
                "/swap" = {
                  mountpoint = "/swap";
                  mountOptions = [ "subvol=swap" ] ++ btrfsMountOptions;
                  swap.swapfile.size = "16G";
                };
              };
            };
          };
        };
      };
    };
  };

  boot.initrd.luks.devices.crypt = {
    device = "/dev/disk/by-partlabel/luks";
    allowDiscards = true;
  };
}
