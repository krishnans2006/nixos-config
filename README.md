# NixOS Config

My NixOS configuration.

The system:
- KDE Plasma 6
- Zsh (oh-my-zsh) + Atuin
- Firefox
- Git, SSH, GnuPG, etc.
- Other apps as needed

The configuration:
- Multi-device (PC, laptop)
- Nixpkgs `unstable`
- Flakes
- Secrets management with `sops` and `sops-nix` (as a submodule)
- Home Manager (heavily used)
- Organized, readable, tons of comments

## Manual Configuration Steps

Despite trying to use NixOS for most of the system configuration, some steps still need to be done manually.

Note: This list is incomplete. Also, it would be nice to automate these into a `curl`-able script at some point.

- `nix-shell -p git age ssh-to-age`
- Generate a user SSH key, copy it to GitHub and all remotes that are SSHFS-mounted
- `git clone git@github.com:krishnans2006/nixos-config.git ~/NixOS`
- Follow instructions below to allow secrets access (using key derived from SSH key)
- Import gpg.key from an external source
- Remove the password for `kdewallet` (KWallet)
- Add any autostart applications through KDE settings
- Atuin: `atuin login -u krishnan`, enter password (Bitwarden) and leave key blank (it's already pre-configured)
- Tailscale: `sudo tailscale login`, `sudo tailscale set --ssh --operator=krishnan`
- Waydroid: `sudo waydroid init -s GAPPS -f`
- Secure Boot: (see [documentation](https://github.com/nix-community/lanzaboote/blob/master/docs/QUICK_START.md))
  - `sudo , sbctl create-keys`
  - `modules.secure-boot.enable = true;`
  - Set BIOS to setup mode (erase Platform Key)
  - `sudo sbctl enroll-keys --microsoft`

## Command Snippets

### Rebuild system after changes

```bash
sudo nixos-rebuild switch --flake '.?submodules=1'
```

### Update package versions

```bash
sudo nix flake update
sudo nixos-rebuild switch --flake '.?submodules=1'
```

### Update secrets

```bash
sops secrets/secrets.yaml
```

### Allow a new system to access secrets

First, generate an `age` keypair and get its public key:

```bash
mkdir -p ~/.config/sops/age
cp $HOME/.ssh/id_ed25519 /tmp/id_ed25519
ssh-keygen -p -N "" -f /tmp/id_ed25519
ssh-to-age -private-key -i /tmp/id_ed25519 > ~/.config/sops/age/keys.txt

age-keygen -y ~/.config/sops/age/keys.txt
```

Then, allow it to access secrets in `.sops.yaml`: 

```yaml
keys:
  - ...
  - &system ageXXXXXX
creation_rules:
  - path_regex: secrets/[^/]+\.(yaml|json|env|ini)$
    key_groups:
      - age:
        - ...
        - *system
```

Finally, re-encrypt the secrets:

```bash
sops updatekeys secrets/secrets.yaml
sops updatekeys secrets/secrets-home.yaml
sudo nixos-rebuild switch --flake '.?submodules=1'
```

## Configure impermanence + disks (disko) + install

This assumes that the configuration has a `disk.nix` file that sets up the disk partitions, filesystems, etc.

It also assumes a valid `.ssh/id_ed25519` key exists and secrets access has been set up.

```bash
eval `ssh-agent -s`
ssh-add
ssh -T git@github.com  # Test SSH access to GitHub
git clone --recurse-submodules git@github.com:krishnans2006/nixos-config.git ~/NixOS
cd NixOS

sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode destroy,format,mount --flake '.#krishnan-<SYSTEM>'
lsblk  # Verify disks/partitions are correct
sudo btrfs subvolume list /mnt  # Verify subvolumes are correct

sudo nixos-generate-config --no-filesystems --root /mnt --dir ./systems/krishnan-<SYSTEM>/hardware.nix

sudo nixos-install --flake '.?submodules=1#krishnan-<SYSTEM>' --no-root-password
# If it fails by using the host ssh key, run the command again with no modifications

cp ~/.config/sops/age/keys.txt /mnt/persist/home/krishnan/.config/sops/age
cp ~/.ssh/id_ed25519 /mnt/persist/home/krishnan/.ssh
cp ~/.ssh/id_ed25519.pub /mnt/persist/home/krishnan/.ssh

sudo reboot now
```
