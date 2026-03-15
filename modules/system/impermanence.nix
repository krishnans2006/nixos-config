# Inspired by:
# - https://github.com/Misterio77/nix-config/blob/ffd3478bda5dbe53235d25898ba39585f9e088f4/hosts/common/optional/ephemeral-btrfs.nix
# - https://github.com/nix-community/impermanence#btrfs-subvolumes
{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.modules.impermanence;

  root = config.fileSystems."/";
in
{
  options.modules.impermanence = {
    enable = mkEnableOption "Enable Impermanence";
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = root.fsType == "btrfs";
        message = "Must have a btrfs root filesystem to use Impermanence";
      }
      {
        assertion = config.boot.initrd.systemd.enable == false;
        message = "The impermanence module doesn't work with initrd systemd";
      }
      # TODO: Add assertion for postCreateHook in disk.nix to make sure
      # root-blank and home-blank snapshots are created correctly
    ];

    # Info about neededForBoot:
    # > If set, this file system will be mounted in the initial ramdisk. Note
    # > that the file system will always be mounted in the initial ramdisk if
    # > its mount point is one of the following: /, /nix, /nix/store, /var,
    # > /var/log, /var/lib, /var/lib/nixos, /etc, /usr.
    # (from https://nixos.org/manual/nixos/unstable/options#opt-fileSystems._name_.neededForBoot)
    
    # Also, note that impermanence requires:
    # All your persistent and ephemeral storage volumes marked with neededForBoot
    # So basically every subvolume in disk.nix needs to be marked with neededForBoot
    # /
    fileSystems."/home".neededForBoot = lib.mkDefault true;
    fileSystems."/var/cache".neededForBoot = lib.mkDefault true;
    # /var/log
    fileSystems."/var/lib".neededForBoot = lib.mkDefault true;
    # /nix
    fileSystems."/persist".neededForBoot = lib.mkDefault true;
    # /swap (not needed since it's swap)

    environment.persistence."/persist" = {
      enable = true;
      hideMounts = true;
      directories = [
        # Already persisted:
        # - /var/log
        # - /var/lib
        # - /persist
        # - /nix
        # - /swap
        "/var/lib/nixos"
        "/var/lib/systemd"
      ];
      files = [
        "/etc/machine-id"
      ];
    };

    boot.initrd = {
      supportedFilesystems = [ "btrfs" ];

      # A recursive delete isn't used, since we don't want to delete some subvolumes
      # See systems/*/disk.nix
      # So, some subvolumes are deleted (/var/cache)
      # Some are deleted and restored from a blank snapshot (/ and /home)
      # And some are persisted (/persist, /var/log, /var/lib, /swap)
      #
      # Note: This needs to change drastically if boot.initrd.systemd.enable
      # is enabled (probably using systemd.services wantedBy initrd.target)
      # See https://github.com/Misterio77/nix-config/blob/ffd3478bda5dbe53235d25898ba39585f9e088f4/hosts/common/optional/ephemeral-btrfs.nix
      postResumeCommands = ''
        mkdir -p /tmp
        MOUNTPOINT=$(mktemp -d)
        (
          mount -t btrfs ${root.device} "$MOUNTPOINT"
          trap 'umount $MOUNTPOINT; rm -d $MOUNTPOINT' EXIT

          echo "Creating needed directories"
          mkdir -p "$MOUNTPOINT"/persist/var/{log,lib/{nixos,systemd}}
          if [ -e "$MOUNTPOINT/dont-wipe" ]; then
            echo "Skipping wipe since $MOUNTPOINT/dont-wipe exists"
          else
            echo "Deleting root subvolume (/)"
            btrfs subvolume delete -R "$MOUNTPOINT/root"
            echo "Restoring root subvolume from root-blank"
            btrfs subvolume snapshot "$MOUNTPOINT/root-blank" "$MOUNTPOINT/root"

            echo "Deleting home subvolume (/home)"
            btrfs subvolume delete -R "$MOUNTPOINT/home"
            echo "Restoring home subvolume from home-blank"
            btrfs subvolume snapshot "$MOUNTPOINT/home-blank" "$MOUNTPOINT/home"

            echo "Deleting cache subvolume (/var/cache)"
            btrfs subvolume delete -R "$MOUNTPOINT/cache"
          fi
        )
      '';
    };
  };
}
