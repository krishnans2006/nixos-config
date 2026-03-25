{ inputs, ... }:

with inputs;

{
  imports = [
    # Base configuration
    ../../base/home.nix

    # Custom modules
    (import-tree ../../modules/home)
    (import-tree ../../modules/packages)
  ];

  modules.plasma.enable = true;
  modules.tailscale.enable = true;
  modules.shell = {
    enable = true;
    enableDotfiles = true;
    enableTheme = true;
    enableAtuin = true;
  };
  modules.git.enable = true;
  modules.ssh.enable = true;

  modules.packages = {
    utils.enable = true;
    zen-browser.enable = true;
    zen-browser.autostart = true;
    bitwarden-desktop.enable = true;
    bitwarden-desktop.autostart = true;
    firefox.enable = false;
    thunderbird.enable = false;
  };
  
  programs.firefox.profiles.default.settings."identity.fxaccounts.account.device.name" = "krishnan-pc";
}
