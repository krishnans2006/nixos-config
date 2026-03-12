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
  };

  modules.packages = {
    zen-browser.enable = true;
    zen-browser.autostart = true;
    bitwarden-desktop.enable = true;
    bitwarden-desktop.autostart = true;
  };
  
  programs.firefox.profiles.default.settings."identity.fxaccounts.account.device.name" = "krishnan-lap";

  programs.plasma.configFile.kwinrc.Xwayland.Scale = "1.25";
}
