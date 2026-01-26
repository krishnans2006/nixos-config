{ inputs, ... }:

with inputs;

{
  imports = [
    # Base configuration
    ../../base/home.nix

    # Custom modules
    (import-tree ../../modules/home)
  ];

  modules.plasma.enable = true;
  modules.tailscale.enable = true;
  modules.thunderbird.enable = false;

  programs.firefox.profiles.default.settings."identity.fxaccounts.account.device.name" = "krishnan-vivo";

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
