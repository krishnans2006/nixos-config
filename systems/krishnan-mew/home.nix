{ inputs, root, lib, ... }:

with inputs;

{
  imports = [
    # Profiles
    (root + "/profiles/base/home.nix")
    (root + "/profiles/default/home.nix")
    (root + "/profiles/headless/home.nix")

    # Custom modules
    (import-tree (root + "/modules/home"))
  ];

  modules.secrets.enable = lib.mkForce false;  # Secrets-free config

  modules.git.enableGithubCLIAutoLogin = lib.mkForce false;  # (needs secrets)
  modules.shell.enableAtuin = lib.mkForce false;  # (needs secrets)
}
