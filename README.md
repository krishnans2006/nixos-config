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
- "One-file" setup (as opposed to the heavily-nested standard)
- Nixpkgs `unstable`
- Flakes
- Secrets management with `sops` and `sops-nix` (as a submodule)
- Home Manager (heavily used)
- Organized, readable, tons of comments

## Manual Configuration Steps

Despite trying to use NixOS for most of the system configuration, some steps still need to be done manually.

Note: This list is incomplete.

- Generate a user SSH key, copy it to GitHub and all remotes that are SSHFS-mounted
- Remove the password for `kdewallet` (KWallet)
- Tailscale: `sudo tailscale login`, `sudo tailscale set --ssh --operator=krishnan`

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
