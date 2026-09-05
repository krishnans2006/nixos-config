{ import-tree, root, ... }:

{
  imports = [
    (import-tree "${root}/modules/home")
    #
  ];

  programs.home-manager.enable = true;
  home.stateVersion = "25.05";

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
