{ import-tree, root, ... }:

{
  imports = [
    # Custom modules
    (import-tree "${root}/modules/home")
  ];

  modules.shell = {
    enable = true;
    enableDotfiles = true;
    enableTheme = true;
    enableAtuin = true;
    enableZoxide = true;
  };
  modules.direnv.enable = true;
  modules.git = {
    enable = true;
    enablePdfDiff = false;
  };
  modules.ssh.enable = true;
  modules.tailscale.enable = true;
}
