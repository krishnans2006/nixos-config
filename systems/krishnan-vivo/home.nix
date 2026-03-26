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
    libreoffice.enable = true;
    jetbrains.enableAll = false;
    zed-editor.enable = true;
  };

  programs.firefox.profiles.default.settings."identity.fxaccounts.account.device.name" =
    "krishnan-vivo";

  programs.plasma.configFile.kwinrc.Xwayland.Scale = "1.25";
  programs.plasma.input.keyboard.model = "asus_laptop";
  programs.plasma.input.touchpads = [
    {
      enable = true;
      vendorId = "2808";
      productId = "0233";
      name = "ASCF1200:00 2808:0233 Touchpad";
      naturalScroll = true;
    }
  ];
}
