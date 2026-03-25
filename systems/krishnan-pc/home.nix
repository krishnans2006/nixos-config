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
  modules.thunderbird.enable = false;
  modules.shell = {
    enable = true;
    enableDotfiles = true;
    enableTheme = true;
    enableAtuin = true;
  };

  modules.packages = {
    utils.enable = true;
    zen-browser.enable = true;
    zen-browser.autostart = true;
    bitwarden-desktop.enable = true;
    bitwarden-desktop.autostart = true;
  };
  
  programs.firefox.profiles.default.settings."identity.fxaccounts.account.device.name" = "krishnan-pc";
}
