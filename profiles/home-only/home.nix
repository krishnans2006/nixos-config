{ import-tree, root, ... }:

{
  imports = [
    (import-tree (root + "/modules/home"))
    #
  ];

  # Standalone Home Manager nixpkgs config (only for non-NixOS hosts without useGlobalPkgs)
  nixpkgs.config.allowUnfree = true;

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
