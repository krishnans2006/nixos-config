{ inputs, root, ... }:

with inputs;

{
  imports = [
    # Base configuration
    "${root}/base/home.nix"

    # Custom modules
    (import-tree "${root}/modules/home")
    (import-tree "${root}/modules/packages")
  ];

  modules.impermanence.enable = true;

  modules.plasma.enable = true;
  modules.tailscale.enable = true;
  modules.shell = {
    enable = true;
    enableDotfiles = true;
    enableTheme = true;
    enableAtuin = true;
    enableZoxide = true;
  };
  modules.direnv.enable = true;
  modules.git.enable = true;
  modules.ssh.enable = true;

  modules.packages = {
    utils.enable = true;
    chat-apps.enable = true;
    chat-apps.autostart = false;
    zen-browser.enable = true;
    zen-browser.autostart = false;
    bitwarden-desktop.enable = true;
    bitwarden-desktop.autostart = false;
    firefox.enable = false;
    thunderbird.enable = false;
    libreoffice.enable = true;
    jetbrains.enableAll = false;
    zed-editor.enable = true;
  };

  programs.firefox.profiles.default.settings."identity.fxaccounts.account.device.name" = "krishnan-lap";

  programs.plasma.configFile.kwinrc.Xwayland.Scale = "1.25";

  programs.plasma.input.touchpads = [
    {
      enable = false;
      vendorId = "0002";
      productId = "0007";
      name = "SynPS/2 Synaptics TouchPad";
      naturalScroll = true;
    }
  ];
}
