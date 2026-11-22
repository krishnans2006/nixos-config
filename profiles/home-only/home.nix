{ import-tree, pkgs, root, ... }:

{
  imports = [
    (import-tree (root + "/modules/home"))
    #
  ];

  # Standalone Home Manager nixpkgs config (only for non-NixOS hosts without useGlobalPkgs)
  nixpkgs.config.allowUnfree = true;

  # Set up binary cache (nixcache.krishy.dev)
  nix = {
    package = pkgs.nix;
    settings = {
      extra-substituters = [ "https://nixcache.krishy.dev" ];
      extra-trusted-public-keys = [
        "nixcache.krishy.dev:oBY+iTZ6JvHT4lHj12RLdTG75Azcgx+tt14y1ELUct4="
      ];
    };
  };

  # Sync nixpkgs.config to ~/.config/nixpkgs/config.nix for comma, nix-shell, etc.
  modules.nixpkgs-config.enable = true;

  modules.nix-user-chroot.enable = true;

  modules.plasma.enable = false;
  modules.fonts.enable = false;
  modules.tailscale.enable = false;
  modules.shell = {
    enable = true;
    enableDotfiles = true;
    enableTheme = true;
    enableAtuin = false;
    enableZoxide = true;
  };
  modules.direnv.enable = true;
  modules.git = {
    enable = true;
    enablePdfDiff = false;
  };
  modules.ssh = {
    enable = true;
    enableAuthorizedKeys = true;
  };
}
