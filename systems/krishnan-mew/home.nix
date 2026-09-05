{ inputs, root, lib, ... }:

with inputs;

{
  imports = [
    # Base configuration
    "${root}/base/home.nix"

    # Profiles
    "${root}/profiles/headless/home.nix"

    # Custom modules
    (import-tree "${root}/modules/home")
  ];

  modules.secrets.enable = lib.mkForce false;  # Secrets-free config

  modules.shell.enableAtuin = lib.mkForce false;  # (needs secrets)
}
